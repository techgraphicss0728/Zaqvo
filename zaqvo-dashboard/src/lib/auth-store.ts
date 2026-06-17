const ADMIN_TOKEN_KEY = 'zaqvo-dashboard-admin-token'

/** Per-tab storage so multiple dashboard users can stay signed in across browser tabs. */
function storage() {
  return window.sessionStorage
}

/** One-time move from shared localStorage (older builds overwrote sessions across tabs). */
export function migrateLegacyAdminToken(): void {
  const legacy = window.localStorage.getItem(ADMIN_TOKEN_KEY)?.trim()
  if (!legacy || storage().getItem(ADMIN_TOKEN_KEY)) return
  storage().setItem(ADMIN_TOKEN_KEY, legacy)
  window.localStorage.removeItem(ADMIN_TOKEN_KEY)
}

export function getAdminToken(): string {
  return storage().getItem(ADMIN_TOKEN_KEY)?.trim() ?? ''
}

export function setAdminToken(token: string): void {
  const normalized = token.trim()
  if (!normalized) {
    storage().removeItem(ADMIN_TOKEN_KEY)
    return
  }
  storage().setItem(ADMIN_TOKEN_KEY, normalized)
}

export function clearAdminToken(): void {
  storage().removeItem(ADMIN_TOKEN_KEY)
}
