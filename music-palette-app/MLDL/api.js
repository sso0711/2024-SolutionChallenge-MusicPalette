"use strict";

// Import required modules: fetch for HTTP requests and fs for file system operations
const fetch = require("node-fetch");
const fs = require("fs");

// Define constants for the API URL and an access token for authentication
const API_URL = "https://api.cyanite.ai/graphql"; 
const ACCESS_TOKEN = "YOUR_ACCESS_TOKEN_HERE"; // Replace with your actual access token

// Define a GraphQL mutation for requesting a file upload URL
const fileUploadRequestMutation = `
  mutation fileUploadRequest {
    fileUploadRequest {
      id
      uploadUrl
    }
  }
`;

// Define a GraphQL mutation for creating a library track in the remote system
const libraryTrackCreateMutation = /* GraphQL */ `
  mutation LibraryTrackCreate($input: LibraryTrackCreateInput!) {
    libraryTrackCreate(input: $input) {
      ... on LibraryTrackCreateError {
        message
      }
      ... on LibraryTrackCreateSuccess {
        createdLibraryTrack {
          __typename
          id
        }
      }
    }
  }
`;

// Asynchronously request a file upload URL from the API
const requestFileUpload = async () => {
  const result = await fetch(API_URL, {
    method: "POST",
    body: JSON.stringify({
      query: fileUploadRequestMutation
    }),
    headers: {
      Authorization: "Bearer " + ACCESS_TOKEN,
      "Content-Type": "application/json"
    }
  }).then(res => res.json());

  // Log the response for debugging purposes
  console.log("[info] fileUploadRequest response: ");
  console.log(JSON.stringify(result, undefined, 2));

  // Return the file upload request details (ID and URL)
  return result.data.fileUploadRequest;
};

// Asynchronously upload a file to the provided upload URL
const uploadFile = async (filePath, uploadUrl) => {
  const result = await fetch(uploadUrl, {
    method: "PUT",
    body: fs.createReadStream(filePath),
    headers: {
      "Content-Length": fs.statSync(filePath).size // Ensure the Content-Length header is set to the file size
    }
  }).then(res => res);
  // Log the result status for debugging purposes
  console.log(result);
};

// Asynchronously create a library track record in the remote system using the file upload ID
const libraryTrackCreate = async fileUploadRequestId => {
  const result = await fetch(API_URL, {
    method: "POST",
    body: JSON.stringify({
      query: libraryTrackCreateMutation,
      variables: {
        input: {
          title: "My first libraryTrackCreate 3",
          uploadId: fileUploadRequestId
        }
      }
    }),
    headers: {
      Authorization: "Bearer " + ACCESS_TOKEN,
      "Content-Type": "application/json"
    }
  }).then(res => res.json());

  // Log the libraryTrackCreate response for debugging
  console.log("[info] libraryTrackCreate response: ");
  console.log(JSON.stringify(result, undefined, 2));

  // Return the libraryTrackCreate result
  return result.data.libraryTrackCreate;
};

// Asynchronously enqueue a library track for processing
const libraryTrackEnqueue = async libraryTrackId => {
  const mutationDocument = /* GraphQL */ `
    mutation LibraryTrackEnqueue($input: LibraryTrackEnqueueInput!) {
      libraryTrackEnqueue(input: $input) {
        __typename
        ... on LibraryTrackEnqueueError {
          message
        }
        ... on LibraryTrackEnqueueSuccess {
          enqueuedLibraryTrack {
            id
          }
        }
      }
    }
  `;
  const result = await fetch(API_URL, {
    method: "POST",
    body: JSON.stringify({
      query: mutationDocument,
      variables: { input: { libraryTrackId } }
    }),
    headers: {
      Authorization: "Bearer " + ACCESS_TOKEN,
      "Content-Type": "application/json"
    }
  }).then(res => res.json());
  // Log the libraryTrackEnqueue response for debugging
  console.log("[info] libraryTrackEnqueue response: ");
  console.log(JSON.stringify(result, undefined, 2));

  // Check for errors in the enqueue operation and throw an exception if found
  if (result.data.libraryTrackEnqueue.__typename.endsWith("Error")) {
    throw new Error(result.data.inDepthAnalysisFileUpload.message);
  }

  // Return the result data
  return result.data;
};

// Main function to orchestrate the upload and processing flow
const main = async () => {
  try {
    // Request a file upload URL
    console.log("[info] request file upload");
    const { id, uploadUrl } = await requestFileUpload();
    // Upload the file
    console.log("[info] upload file");
    await uploadFile("piano-sample.mp3", uploadUrl);
    console.log("[info] create InDepthAnalysis")
    console.log(id)
    await libraryTrackCreate(id);
    console.log("[info] File upload and processing completed successfully!");
    await libraryTrackEnqueue(16621933);
  } catch (error) {
    console.error("[error] An error occurred:", error);
    process.exitCode = 1;
  }
};