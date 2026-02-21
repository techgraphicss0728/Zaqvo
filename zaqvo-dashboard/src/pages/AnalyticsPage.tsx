import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

export function AnalyticsPage() {
  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold">Analytics</h2>
      <Card>
        <CardHeader>
          <CardTitle>Analytics & charts</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground">
            Charts and analytics. Use recharts and data from API.
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
