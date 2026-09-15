class Quartermaster < Formula
  desc "Cuánta cuota te queda en todos tus perfiles de Claude Code, Codex y opencode"
  homepage "https://github.com/legiosai/quartermaster"
  url "https://github.com/legiosai/quartermaster/archive/refs/tags/v0.1.14.tar.gz"
  sha256 "3bf95b063f61ec15ac2a0277c830cb890fbffe1e628a929b5de5f5c39b9b48da"
  license "MIT"
  head "https://github.com/legiosai/quartermaster.git", branch: "main"

  # qm lee el TypeScript directo, sin paso de build. Eso recién existe desde
  # Node 22.6, así que la dependencia no es opcional ni es "cualquier node".
  depends_on "node"

  def install
    libexec.install Dir["*"]

    # El lanzador del repo (bin/qm) existe para buscar un Node que sirva en
    # máquinas donde `node` es un 20 y las versiones nuevas viven en nvm. Acá no
    # hace falta buscar nada: Homebrew sabe exactamente cuál es.
    (bin/"qm").write <<~SH
      #!/bin/sh
      exec "#{Formula["node"].opt_bin}/node" "#{libexec}/src/cli/qm.ts" "$@"
    SH
    chmod 0755, bin/"qm"
  end

  # La barra como servicio. brew no deja arrancar nada desde el install (corre en
  # sandbox), y registrar un agente de arranque sin que nadie lo pida es lo que
  # se sacó del postinstall de npm. Así queda a un comando que brew mismo imprime
  # al terminar: `brew services start quartermaster` la muestra ya y en cada
  # inicio de sesión. PATH con el bin de Homebrew: swiftc está en /usr/bin, pero
  # la barra llama a qm y launchd no le pasa el PATH del shell.
  service do
    run macos: [opt_libexec/"bin/qm-barra"], linux: [opt_libexec/"bin/qm-indicator"]
    environment_variables PATH: std_service_path_env
    log_path var/"log/quartermaster.log"
    error_log_path var/"log/quartermaster.log"
  end

  def caveats
    <<~EOS
      El comando es `qm`. Las superficies gráficas viven en la fórmula:

        #{libexec}/bin/qm-barra        la barra de menú de macOS (o `brew services start quartermaster`)
        #{libexec}/bin/qm-indicator    el item de la barra de GNOME
        #{libexec}/bin/qm-web          el tablero en el navegador

      El item de GNOME necesita además PyGObject y GTK 3, que no vienen por acá.
    EOS
  end

  test do
    # Sin cuentas en la máquina, qm lo dice y sale con 0: eso es lo que tiene
    # que pasar en el sandbox de brew, donde no hay ningún perfil.
    salida = shell_output("#{bin}/qm --help")
    assert_match "cuánta cuota te queda", salida
    assert_match "\"perfiles\"", shell_output("#{bin}/qm --json --breve")
  end
end
