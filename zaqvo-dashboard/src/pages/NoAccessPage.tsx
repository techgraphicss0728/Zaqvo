type Props = {
  userName?: string
}

export function NoAccessPage({ userName }: Props) {
  return (
    <div className="mx-auto flex max-w-lg flex-col items-center justify-center py-16 text-center">
      <h2 className="text-xl font-semibold tracking-tight">No dashboard access</h2>
      <p className="mt-2 text-sm text-muted-foreground">
        {userName ? `${userName}, your` : 'Your'} role does not include access to any dashboard screens.
        Contact a super admin to update your privileges.
      </p>
    </div>
  )
}
