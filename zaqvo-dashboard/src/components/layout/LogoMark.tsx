import { cn } from '@/lib/utils'
import logoZaqvo from '@/assets/LOGO_ZAQVO.png'

type Props = {
  className?: string
  /** Max width of the logo image (height scales). */
  maxWidth?: number
}

export function LogoMark({ className, maxWidth = 168 }: Props) {
  return (
    <div className={cn('flex items-center', className)}>
      <img
        src={logoZaqvo}
        alt="Zaqvo"
        width={maxWidth}
        height={40}
        className="h-10 w-auto max-w-full object-contain object-left"
        style={{ maxWidth }}
      />
    </div>
  )
}
