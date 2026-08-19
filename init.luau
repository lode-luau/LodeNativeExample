-- Type-only package entry for the native implementation.

export type NativeExample = {
    add: (left: number, right: number) -> number,
    identity: (value: string) -> string,
}

return {} :: NativeExample
