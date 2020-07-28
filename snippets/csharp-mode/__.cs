# -*- mode: snippet -*-
# --
namespace `(s-replace "/" "." (string-remove-suffix "/" (file-relative-name default-directory (projectile-project-root)) ) )` {
public class `(file-name-sans-extension (buffer-name) )`
{

}
}
