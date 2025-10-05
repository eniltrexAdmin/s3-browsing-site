Project that deploys an app to browse the content of an s3.

FE is secured with basic authentication.

BE is just a couple of lambdas.

The infra for BE is just 2 lambdas.

Pipeline is to deploy first the API GW, then the two lambdas depending on that
reusing the same lambda module. Executed by github.

The devops side is that whenever the code in the lambdas change they are being
deployed, but it assumes an static infra which is the existence of the API GW.

Infra doesn't have "environments" it's all in production.


FE pipeline is independent and I havet started yet.

![Architecture Diagram](architecture-1.png)


## DEcisions

I am keeping woth zip files and not Docker images for the following reasons:
1. I already had it
2. I need to deal with ECR in the main infra probably.
3. A big advantage is to be able to test in local the exact same thing, but it's not really useful, I am not respecting clean architecture, I'm coupled with ifnra in s3 etc, it's no use to test in local (also I could test without docker)
4. The other big advantage is the pipeline, fast cycle, deploy etc, but that's not going to be the case here, i will probably forget about it once it's deployed once.

## Stupid stuff:

If I were to repeat this project for each bucket I have, the lambda code will be stupidly duplicated
it could be reused, the problem is that the role for the lambda needs access to each s3 bucket you will 
need to list /presign.

but ti could be completely separated, and deploying a "new bucket page" would be just frontend, and adding
the permissions to teh lambda role.

Also the "just frontend" is discussable, we could have a generic frontend, and each domain /subdomain
gives you access to a bucket. 

We'll see the relationship betweend domain <-> bucket, but proably it will be the bucket name as subdomain

bucket-name.bucket-navigator.eniltrex.biz  (not sure the eniltrex if its com or bix or it's going to be cesc).

I guess I will see it clearly how to have several tenants (buckets) once I do that. 

I don't want to spend too much time in this project, I am just interested in navigating a single bucket.
but if not, I would spend time thinkgin if I should be able to navigate thouth all my buckets, or well, 
the relatinship between user <--> buckets I want to navigate 