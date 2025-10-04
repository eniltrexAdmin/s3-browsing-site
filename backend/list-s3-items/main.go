package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
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

func handleRequest(ctx context.Context, event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Fatalf("unable to load SDK config, %v", err)
	}

	log.Printf("Full request body: %s", event.Body)
	log.Printf("Full event: %+v", event)

	input := S3ListInput{
		Bucket: event.QueryStringParameters["bucket"],
		Key:    event.QueryStringParameters["key"],
	}

	inputJson, _ := json.Marshal(input)
	log.Printf("Lambda received input: %s", string(inputJson))

	// Create S3 client
	client := s3.NewFromConfig(cfg)

	// Call the ListObjectsV2 API
	output, err := client.ListObjectsV2(ctx, &s3.ListObjectsV2Input{
		Bucket: aws.String(input.Bucket),
		Prefix: aws.String(input.Key),
		//Delimiter: aws.String("/"), // important: lists only one level deep
	})
	if err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: 500,
			Body:       fmt.Sprintf("failed to list objects: %v", err),
		}, nil
	}

	var items []string
	// Files
	//for _, obj := range output.Contents {
	//	items = append(items, strings.TrimPrefix(*obj.Key, prefix))
	//}
	//
	//// "Subdirectories"
	//for _, cp := range output.CommonPrefixes {
	//	items = append(items, strings.TrimPrefix(*cp.Prefix, prefix))
	//}
	for _, obj := range output.Contents {
		items = append(items, *obj.Key)
	}
	resp := S3ListResponse{Items: items}

	body, err := json.Marshal(resp)
	if err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: 500,
			Body:       fmt.Sprintf("failed to marshal response: %v", err),
		}, nil
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       string(body),
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
	}, nil
}

func main() {
	lambda.Start(handleRequest)

}
