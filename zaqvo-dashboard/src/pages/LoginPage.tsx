import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

export function LoginPage() {
  const navigate = useNavigate()
  const [loading, setLoading] = useState(false)

  const handleLogin = async () => {
    setLoading(true)
    // TODO: call auth API, store token, redirect
    setTimeout(() => {
      setLoading(false)
      navigate('/')
    }, 500)
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-gray-100 dark:bg-gray-900">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>Zaqvo Dashboard</CardTitle>
          <p className="text-sm text-muted-foreground">Sign in to access reports and analytics.</p>
        </CardHeader>
        <CardContent>
          <Button className="w-full" onClick={handleLogin} disabled={loading}>
            {loading ? 'Signing in...' : 'Sign in'}
          </Button>
        </CardContent>
      </Card>
    </div>
  )
}
