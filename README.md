# Dotfiles

## Installation

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ksera524/dotfiles/main/bootstrap.sh)
```

## VS Code Settings

### RustOwl Extension Colors

The following color scheme is configured for the RustOwl extension to provide clear visual distinction for Rust's ownership and borrowing system. Colors are chosen for accessibility, including for color-blind users:

| Feature | Color | HSL Value | Description |
|---------|-------|-----------|-------------|
| **Immutable Borrow** | Cyan (明るい青) | `hsla(200, 100%, 50%, 0.8)` | 不変借用を示す下線 |
| **Lifetime** | White (白) | `hsla(0, 0%, 100%, 0.8)` | ライフタイムを示す下線 |
| **Move/Call** | Yellow (黄色) | `hsla(60, 100%, 50%, 0.8)` | ムーブ/関数呼び出しを示す下線 |
| **Mutable Borrow** | Red (赤) | `hsla(0, 100%, 50%, 0.8)` | 可変借用を示す下線 |
| **Outlive** | Gray (灰色) | `hsla(0, 0%, 50%, 0.8)` | ライフタイム制約を示す下線 |

これらの色は色覚異常の方にも識別しやすいよう、明度差と色相差を大きく設定しています。