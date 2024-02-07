# Use an official Node runtime as a parent image
FROM node:alpine

# Add packages
RUN apk add --no-cache curl

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . .

# Install any needed packages specified in package.json
RUN npm install

# Make port 3000 available to the world outside this container
EXPOSE 3000

# Define environment variable
ENV NAME World

# Run server.js when the container launches
CMD ["node", "server.js"]

