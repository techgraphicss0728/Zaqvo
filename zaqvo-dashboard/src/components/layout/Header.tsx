export function Header() {
  return (
    <header className="flex h-16 items-center justify-between border-b border-gray-200 bg-white px-6 dark:border-gray-800 dark:bg-gray-950">
      <h1 className="text-lg font-medium text-gray-800 dark:text-gray-200">
        Dashboard
      </h1>
      <div className="flex items-center gap-4">
        <span className="text-sm text-gray-500">Admin</span>
      </div>
    </header>
  )
}
