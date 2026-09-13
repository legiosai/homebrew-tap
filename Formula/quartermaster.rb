class Quartermaster < Formula
  desc "Cuánta cuota te queda en todos tus perfiles de Claude Code, Codex y opencode"
  homepage "https://github.com/legiosai/quartermaster"
  url "https://github.com/legiosai/quartermaster/archive/refs/tags/v0.1.6.tar.gz"
  sha256 "a141478293130f8b4af5316485f957f84f6f7c50c61f79d4faaf756a5f9afe7e"
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

  def caveats
    <<~EOS
      El comando es `qm`. Las superficies gráficas viven en la fórmula:

        #{libexec}/bin/qm-barra        la barra de menú de macOS
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
