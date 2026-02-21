import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

export function ReportsPage() {
  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold">Reports</h2>
      <Card>
        <CardHeader>
          <CardTitle>Reports & exports</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground">
            Generate and download reports. Connect backend analytics endpoints here.
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
