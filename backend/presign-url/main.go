package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

type PresignResponse struct {
	URL string `json:"url"`
}

func handler(ctx context.Context, event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Printf("Unable to load SDK config: %v", err)
		return errorResponse(http.StatusInternalServerError, err.Error()), nil
	}

	bucket := event.QueryStringParameters["bucket"]
	key := event.QueryStringParameters["key"]

	if bucket == "" || key == "" {
		log.Printf("bucket and key query parameters are required")
		return errorResponse(http.StatusBadRequest, "bucket and key query parameters are required"), nil
	}

	client := s3.NewFromConfig(cfg)
	presigner := s3.NewPresignClient(client)

	psReq, err := presigner.PresignGetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(key),
	}, func(opts *s3.PresignOptions) {
		opts.Expires = time.Duration(3600 * int64(time.Second))
	})
	if err != nil {
		log.Printf("Couldn't get a presigned request to get %v:%v. Here's why: %v\n",
			bucket, key, err)
		return errorResponse(http.StatusInternalServerError, err.Error()), nil
	}

	respBody, err := json.Marshal(PresignResponse{URL: psReq.URL})
	if err != nil {
		log.Printf("Failed to marshal response: %v", err)
		return errorResponse(http.StatusInternalServerError, err.Error()), nil
	}

	return events.APIGatewayProxyResponse{
		StatusCode: http.StatusOK,
		Body:       string(respBody),
		Headers: map[string]string{
			"Content-Type":                 "application/json",
			"Access-Control-Allow-Origin":  "*",
			"Access-Control-Allow-Methods": "GET,OPTIONS",
			"Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key",
		},
	}, nil
}

func errorResponse(status int, msg string) events.APIGatewayProxyResponse {
	return events.APIGatewayProxyResponse{
		StatusCode: status,
		Body:       fmt.Sprintf(`{"error":"%s"}`, msg),
		Headers: map[string]string{
			"Content-Type":                 "application/json",
			"Access-Control-Allow-Origin":  "*",
			"Access-Control-Allow-Methods": "GET,OPTIONS",
			"Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key",
		},
	}
}

func main() {
	lambda.Start(handler)
}
