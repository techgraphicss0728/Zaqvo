import { useMemo, useState } from 'react'
import { ArrowLeft, ShieldCheck, Smartphone } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Button } from '@/components/ui/button'
import { LogoMark } from '@/components/layout/LogoMark'
import { setAdminToken } from '@/lib/auth-store'
import { ApiError } from '@/lib/api-client'
import { sendAdminLoginOtp, verifyAdminLoginOtp } from '@/lib/admin-auth-api'
import { authUserFromApi, type AuthUser } from '@/hooks/usePermissions'
import { useToast } from '@/hooks/useToast'

export type LoginUser = AuthUser

type Props = {
  onLogin: (user: LoginUser) => void
}

type LoginStep = 'mobile' | 'otp'

export function LoginPage({ onLogin }: Props) {
  const { toast } = useToast()
  const [step, setStep] = useState<LoginStep>('mobile')
  const [phone, setPhone] = useState('')
  const [otp, setOtp] = useState('')
  const [loading, setLoading] = useState(false)

  const canSendOtp = useMemo(() => /^\d{10}$/.test(phone), [phone])
  const canVerifyOtp = useMemo(() => /^\d{4,6}$/.test(otp), [otp])

  const sendOtp = async () => {
    if (!canSendOtp) {
      toast('Enter a valid 10-digit mobile number.', 'error')
      return
    }

    setLoading(true)
    try {
      const response = await sendAdminLoginOtp({ mobile_number: phone })
      setStep('otp')
      setOtp('')
      if (response.dev_mode) {
        toast(
          'Development mode: SMS not sent. Check the API terminal (uvicorn) for your OTP, or set BSNL_AUTH_TOKEN in .env for real SMS.',
          'info',
        )
      } else {
        toast('OTP sent to your mobile number. Valid for 5 minutes.', 'success')
      }
    } catch (e) {
      toast(e instanceof ApiError ? e.message : 'Unable to send OTP. Please try again.', 'error')
    } finally {
      setLoading(false)
    }
  }

  const verifyOtp = async () => {
    if (!canVerifyOtp) {
      toast('Enter the OTP sent to your mobile number.', 'error')
      return
    }

    setLoading(true)
    try {
      const response = await verifyAdminLoginOtp({ mobile_number: phone, otp: otp.trim() })
      setAdminToken(response.access_token)
      toast('Login successful. Welcome back!', 'success')
      onLogin(authUserFromApi(response.admin))
    } catch (e) {
      toast(e instanceof ApiError ? e.message : 'OTP verification failed. Please try again.', 'error')
    } finally {
      setLoading(false)
    }
  }

  const resendOtp = async () => {
    setLoading(true)
    try {
      const response = await sendAdminLoginOtp({ mobile_number: phone })
      if (response.dev_mode) {
        toast('Development mode: check the API terminal for the new OTP.', 'info')
      } else {
        toast('A new OTP has been sent to your mobile number.', 'success')
      }
    } catch (e) {
      toast(e instanceof ApiError ? e.message : 'Unable to resend OTP.', 'error')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-slate-950 via-slate-900 to-cyan-950 px-4 py-10">
      <Card className="w-full max-w-md border-white/10 bg-slate-900/85 text-slate-100 shadow-2xl backdrop-blur">
        <CardHeader className="space-y-4">
          <LogoMark className="justify-center" maxWidth={168} />
          <div className="text-center">
            <CardTitle className="text-2xl">{step === 'otp' ? 'Verify OTP' : 'Admin login'}</CardTitle>
            <CardDescription className="mt-2 text-slate-300">
              {step === 'otp'
                ? `Enter the OTP sent to ${phone}. Dashboard access is granted only after verification.`
                : 'Sign in with your registered mobile number. Access is provisioned by your super admin.'}
            </CardDescription>
          </div>
        </CardHeader>

        <CardContent className="space-y-5">
          {step === 'mobile' ? (
            <div className="space-y-2">
              <Label htmlFor="mobile" className="text-slate-200">
                Mobile number
              </Label>
              <div className="relative">
                <Smartphone className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
                <Input
                  id="mobile"
                  inputMode="numeric"
                  maxLength={10}
                  placeholder="Enter 10-digit mobile number"
                  value={phone}
                  onChange={(event) => setPhone(event.target.value.replace(/\D/g, ''))}
                  className="border-slate-700 bg-slate-950/70 pl-10 text-slate-100 placeholder:text-slate-400"
                />
              </div>
            </div>
          ) : (
            <>
              <div className="space-y-2">
                <Label htmlFor="otp" className="text-slate-200">
                  One-time password
                </Label>
                <Input
                  id="otp"
                  inputMode="numeric"
                  maxLength={6}
                  placeholder="Enter OTP"
                  value={otp}
                  onChange={(event) => setOtp(event.target.value.replace(/\D/g, ''))}
                  className="border-slate-700 bg-slate-950/70 text-slate-100 placeholder:text-slate-400"
                />
              </div>
              <Button
                type="button"
                variant="ghost"
                className="w-full text-slate-300"
                disabled={loading}
                onClick={() => {
                  setStep('mobile')
                  setOtp('')
                }}
              >
                <ArrowLeft className="mr-2 h-4 w-4" />
                Change mobile number
              </Button>
              <Button
                type="button"
                variant="ghost"
                className="w-full text-cyan-300"
                disabled={loading}
                onClick={() => void resendOtp()}
              >
                Resend OTP
              </Button>
            </>
          )}

          <Button
            type="button"
            variant="brand"
            className="w-full"
            disabled={loading || (step === 'otp' ? !canVerifyOtp : !canSendOtp)}
            onClick={() => void (step === 'otp' ? verifyOtp() : sendOtp())}
          >
            {loading ? 'Please wait...' : step === 'otp' ? 'Verify and enter dashboard' : 'Send OTP'}
          </Button>

          <div className="rounded-md border border-emerald-500/30 bg-emerald-500/10 p-3 text-xs text-emerald-200">
            <div className="mb-1 flex items-center gap-2 font-medium">
              <ShieldCheck className="h-4 w-4" />
              Secure OTP login
            </div>
            No password required. Your role and screen access are applied after OTP verification.
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
