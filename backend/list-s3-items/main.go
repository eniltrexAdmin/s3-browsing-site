package list_s3_items

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"log"
)

type S3ListInput struct {
	Bucket string `json:"bucket"`
	Key    string `json:"key"` // This can be the folder/prefix in the bucket
}

type S3ListResponse struct {
	Items []string `json:"items"`
}

func handleRequest(ctx context.Context, input S3ListInput) (S3ListResponse, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Fatalf("unable to load SDK config, %v", err)
	}

	// Create S3 client
	client := s3.NewFromConfig(cfg)

	// Call the ListObjectsV2 API
	output, err := client.ListObjectsV2(ctx, &s3.ListObjectsV2Input{
		Bucket: aws.String(input.Bucket),
		Prefix: aws.String(input.Key),
	})
	if err != nil {
		return S3ListResponse{}, fmt.Errorf("failed to list objects: %v", err)
	}

	var items []string
	for _, obj := range output.Contents {
		items = append(items, *obj.Key)
	}

	return S3ListResponse{Items: items}, nil
}

func main() {
	lambda.Start(handleRequest)

}
