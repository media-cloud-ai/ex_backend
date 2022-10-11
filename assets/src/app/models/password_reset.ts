
export class PasswordReset {
    detail?: string
    error?: string

    constructor(detail?: string, error?: string) {
        this.detail = detail;
        this.error = error;
    }
}

export interface PasswordResetError {
    headers: any,
    status: number,
    statusText: string,
    url: string,
    ok: boolean,
    name: string,
    message: string,
    error?: {
        custom_error_message?: string
    }
}
