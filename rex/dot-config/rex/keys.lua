rex.bind("cmd+shift+,>cmd+shift+,", "client.config.reload")

-- Pane Focus
rex.bind("cmd+shift+h", "pane.focus", { direction = "left" })
rex.bind("cmd+shift+j", "pane.focus", { direction = "down" })
rex.bind("cmd+shift+k", "pane.focus", { direction = "up" })
rex.bind("cmd+shift+l", "pane.focus", { direction = "right" })

-- Pane Splits
rex.unbind("cmd+shift+s")
rex.unbind("cmd+d")

rex.bind("cmd+shift+s", "client.mode.enter", { name = "split", once = true })
rex.bind("split/h", "pane.split", { direction = "left" })
rex.bind("split/j", "pane.split", { direction = "down" })
rex.bind("split/k", "pane.split", { direction = "up" })
rex.bind("split/l", "pane.split", { direction = "right" })

-- Pane Resize
rex.bind("cmd+shift+r", "client.mode.enter", { name = "resize" })
rex.bind("resize/h", "pane.resize", { direction = "left" })
rex.bind("resize/j", "pane.resize", { direction = "down" })
rex.bind("resize/k", "pane.resize", { direction = "up" })
rex.bind("resize/l", "pane.resize", { direction = "right" })

rex.bind("resize/shift+h", "pane.resize", { direction = "left", amount = 15 })
rex.bind("resize/shift+l", "pane.resize", { direction = "right", amount = 15 })

rex.bind("resize/=", "pane.balance")
