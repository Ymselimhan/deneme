# Use Node.js 24 LTS version
FROM node:24-slim

# Create app directory
WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy app source
COPY . .

# Expose the port
EXPOSE 3456

# Start the application
CMD [ "node", "index.js" ]
