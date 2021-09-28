;;; package_configuration/dap-mode/map.el -*- lexical-binding: t; -*-


(map!
  :leader
  "dd" #'dap-hydra
  "dr" #'dap-breakpoint-delete-all
  "ds" #'dap-debug
  )
