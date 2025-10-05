exports.handler = async (event) => {
    const request = event.Records[0].cf.request;
    const headers = request.headers;


    const expectedUser = "${BASIC_USER}";
    const expectedPass = "${BASIC_PASS}";
    const expected = Buffer.from(`$${expectedUser}:$${expectedPass}`).toString('base64');

    const authHeader = headers.authorization && headers.authorization[0].value;
    if (!authHeader || authHeader !== `Basic $${expected}`) {
        const body = 'Unauthorized';
        return {
            status: '401',
            statusDescription: 'Unauthorized',
            headers: {
                'www-authenticate': [{ key: 'WWW-Authenticate', value: 'Basic realm="Restricted"' }],
                'content-type': [{ key: 'Content-Type', value: 'text/plain' }],
                'content-length': [{ key: 'Content-Length', value: body.length.toString() }]
            },
            body,
        };
    }

    return request;
};
