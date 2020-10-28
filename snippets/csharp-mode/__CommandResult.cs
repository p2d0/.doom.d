# -*- mode: snippet -*-
# --
using FinFactory.Core.Abstraction.Application.MediatR.Commands;

namespace `(+yas-csharp/namespace)`
{
    public class `(+yas/filename)` : CommandResult
    {
        public `(+yas/filename)`(int statusCode, string error) : base(statusCode, error)
        {
        }
    }
}
