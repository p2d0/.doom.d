# -*- mode: snippet -*-
# `(setq-local snip-namespace (s-replace "/" "." (string-remove-suffix "/" (file-relative-name default-directory (projectile-project-root)) ) ))`
# `(setq-local filename (file-name-sans-extension (buffer-name)))`
# --

namespace `snip-namespace`
{
    public class `filename` : CommandResult
    {
        public `filename`(int statusCode, string error) : base(statusCode, error)
        {
        }
    }
}
