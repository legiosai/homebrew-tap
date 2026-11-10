class Quartermaster < Formula
  desc "How much quota is left in every Claude Code, Codex and opencode profile"
  homepage "https://github.com/legiosai/quartermaster"
  url "https://github.com/legiosai/quartermaster/archive/refs/tags/v0.1.23.tar.gz"
  sha256 "9e77cbbc08dcd6840292ead5cb900408e652694f604afb0ebc9369033b2e0b9d"
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
      The command is `qm`. The graphical surfaces live in the formula:

        #{libexec}/bin/qm-barra        the macOS menu bar item (or `brew services start quartermaster`)
        #{libexec}/bin/qm-indicator    the GNOME top bar item
        #{libexec}/bin/qm-web          the dashboard in the browser

      The GNOME item also needs PyGObject and GTK 3, which do not come from here.
    EOS
  end

  test do
    # Sin cuentas en la máquina, qm lo dice y sale con 0: eso es lo que tiene
    # que pasar en el sandbox de brew, donde no hay ningún perfil.
    #
    # Desde 0.1.22 la ayuda sale en el idioma del locale, y con un LANG en
    # inglés el «cuánta cuota te queda» de antes no aparecía: el test fallaba
    # en casi todas las máquinas. QM_IDIOMA lo fija, sea cual sea el locale.
    ENV["QM_IDIOMA"] = "en"
    salida = shell_output("#{bin}/qm --help")
    assert_match "how much quota you have left", salida
    assert_match "\"perfiles\"", shell_output("#{bin}/qm --json --breve")
  end
end
