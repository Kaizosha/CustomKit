# Component reference

## Kaizosha Logo

Import `KaizoshaUIKit` and instantiate `KaizoshaLogo(configuration:onOpenCredits:)`.

`LogoConfiguration` provides the following values:

| Value | Default | Behavior |
| --- | --- | --- |
| `size` | 160 | Artwork width in points. The canonical 160:151 aspect ratio remains unchanged. |
| `interactive` | true | Enables direct dragging and elastic return. |
| `hapticsEnabled` | true | Enables tactile travel and release feedback. |
| `motionEnabled` | true | Follows device tilt while the component is visible and active. |
| `refraction` | 1 | Multiplies drag-driven refraction from 0 through 2. The resting canonical finish remains applied. |
| `lightDirection` | (-0.22, -0.32) | Manual shader lighting when device tilt is disabled. |

The optional `onOpenCredits` closure enables a 0.6-second long press and a VoiceOver Open Credits action. The consuming app owns the destination. Omitting the closure removes both actions.

Apps using device lighting include `NSMotionUsageDescription` in their Info.plist. Together and the example app both provide that purpose string.

Reduce Motion limits displacement and removes deformation and device lighting. Reduce Transparency removes shader effects and the shadow. Device lighting stops when the view disappears, the scene becomes inactive, or the corresponding configuration is disabled. Haptic generators detach when the view disappears or haptics are disabled.

The example app owns its one-item list, navigation, customization form, and usage-code view. None of those gallery types are exported by the package.
