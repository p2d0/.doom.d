;;; nixos/editors/.doom.d/package_configuration/python-pytest/python-pytest.el -*- lexical-binding: t; -*-

(add-hook 'python-pytest-finished-hook (lambda () (other-window 1)))
