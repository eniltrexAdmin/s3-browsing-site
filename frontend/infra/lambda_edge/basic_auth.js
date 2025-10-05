exports.handler = async (event) => {
    console.log("Lambda@Edge event:", JSON.stringify(event, null, 2));
    const request = event.Records[0].cf.request;
    const headers = request.headers;


    const expectedUser = "${BASIC_USER}";
    const expectedPass = "${BASIC_PASS}";
    const expected = Buffer.from(`$${expectedUser}:$${expectedPass}`).toString('base64');

    const authHeader = headers.authorization && headers.authorization[0].value;
    console.log("authHeader:", authHeader, "expected(prefix):", expected.slice(0,6));

    if (!authHeader || authHeader !== `Basic $${expected}`) {
        const body = 'Unauthorized';
        console.log("unauthorized — returning 401");

        return {
            status: '401',
            statusDescription: 'Unauthorized',
            headers: {
                'www-authenticate': [{ key: 'www-authenticate', value: 'Basic realm="Restricted"' }],
                'content-type': [{ key: 'content-type', value: 'text/plain' }],
            },
            body: 'Unauthorized'
        };
    }
    console.log("authorized — forwarding request");
    return request;
};
