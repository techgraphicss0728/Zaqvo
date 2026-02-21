import * as React from "react"
import { cn } from "@/lib/utils"

const Badge = React.forwardRef<HTMLSpanElement, React.HTMLAttributes<HTMLSpanElement> & { variant?: 'default' | 'outline' }>(
    ({ className, variant = 'default', ...props }, ref) => (
        <span
            ref={ref}
            className={cn(
                "inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold transition-colors",
                variant === 'default' && "bg-primary text-white",
                variant === 'outline' && "border border-primary text-primary",
                className
            )}
            {...props}
        />
    )
)
Badge.displayName = "Badge"

export { Badge }
