#!/usr/bin/env bash
# Version managers and vendor installers that are not in any RPM repo.
# Every block checks first, so the script is safe to run again.
set -uo pipefail
. "$(dirname "$0")/../lib/common.sh"

info "rustup (Rust toolchain)"
if have rustup || [ -x "$HOME/.cargo/bin/rustup" ]; then
  ok "rustup already installed"
else
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path \
    && ok "rustup installed" || warn "rustup failed"
fi
export PATH="$HOME/.cargo/bin:$PATH"

info "fnm (Node version manager)"
if have fnm || [ -x "$HOME/.local/share/fnm/fnm" ]; then
  ok "fnm already installed"
else
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell \
    && ok "fnm installed" || warn "fnm failed"
fi

info "uv (Python version and project manager)"
if have uv; then
  ok "uv already installed"
else
  curl -LsSf https://astral.sh/uv/install.sh | sh && ok "uv installed" || warn "uv failed"
fi

info "Deno"
if have deno; then
  ok "deno already installed"
else
  curl -fsSL https://deno.land/install.sh | sh -s -- -y && ok "deno installed" || warn "deno failed"
fi

info "Ollama"
if [ "${INSTALL_OLLAMA:-1}" = "1" ]; then
  if have ollama; then
    ok "ollama already installed"
  else
    curl -fsSL https://ollama.com/install.sh | sh && ok "ollama installed" || warn "ollama failed"
  fi
fi

info "Starship prompt"
if have starship; then
  ok "starship already installed"
else
  curl -sS https://starship.rs/install.sh | sh -s -- -y && ok "starship installed" || warn "starship failed"
fi

ok "Toolchain stage finished"
