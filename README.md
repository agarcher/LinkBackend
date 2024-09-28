# Link Backend

This project is a Ruby on Rails application that handles webhooks from Tally forms. It's set up to run in a Docker environment for easy local development.

## Prerequisites

- Docker
- Docker Compose

## Getting Started

1. Clone the repository to your local machine.

2. Navigate to the project directory in your terminal.

3. Build and start the Docker containers:

   ```
   docker-compose up --build
   ```

   This command will build the Docker image (if it hasn't been built before) and start the containers defined in the `docker-compose.yml` file. The `--build` flag ensures that the image is rebuilt if there have been any changes.

4. Once the containers are up and running, you should see logs indicating that the Rails server has started. The application should now be accessible at `http://localhost:3000` (assuming the default Rails port is being used).

## Accessing the Running Container

To access the running web container and execute commands within it, use the following command:

```
docker-compose exec web bash
```

This will open a bash shell inside the running web container, allowing you to run Rails commands, access the console, or make any other changes.

## Useful Docker Compose Commands

- To stop the containers: `docker-compose down`
- To view logs: `docker-compose logs`
- To rebuild and restart containers: `docker-compose up --build`

## Project Structure

- `app/controllers/tally_controller.rb`: Handles the Tally webhook
- `app/controllers/twilio_controller.rb`: Manages Twilio-related functionality
- `app/services/message_sender.rb`: Service for sending messages
- `config/routes.rb`: Defines the application routes
- `config/environments/development.rb`: Development environment configuration
- `config/application.rb`: Main application configuration
- `docker-compose.yml`: Defines the Docker services
- `Gemfile`: Lists the project dependencies