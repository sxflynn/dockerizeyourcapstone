# Dockerize Your Final Capstone

## Tailored for Tech Elevator Cohort 21 Students
This Docker guide and configuration is specifically designed for students of Tech Elevator's Cohort 21.

If you didn't make any changes to the default project structure provided by your Java 21 instructor, and didn't make changes to the `vite.config.js` and `application.properties` you could skip all the way to the Installation section.

## Assumptions
This `Dockerfile` and `docker-compose.yml` solution was created with a very specific environment in mind: Java final capstone for Tech Elevator Cohort 21 students. It could work with your project as long as the assumptions below are true.

### Project directory structure
Before using this solution, verify that your project contains these files in this directory structure:

```
/your-capstone-directory
├── java
│   ├── database
│   │   ├── create.sh
│   │   ├── data.sql
│   │   ├── schema.sql
│   │   ├── drop.sql
│   │   └── user.sql
│   └── src
│       └── main
│           └── resources
│               └── application.properties
├── vue
│   ├── vite.config.js
│   ├── package.json
│   ├── package-lock.json
```

The `Dockerfile` files will also verify and modify the contents of these 2 files below:

### `/vue/vite.config.js`
```
import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  }
})
```

### `/java/src/main/resources/application.properties`
```
# datasource connection properties
spring.datasource.url=jdbc:postgresql://localhost:5432/final_capstone
spring.datasource.name=final_capstone
spring.datasource.username=postgres
spring.datasource.password=postgres1

//jwt properties

server.error.include-stacktrace=never

server.port=9000
```

### sql files
Finally, in the `/java/database` directory, verify that presence of these 4 files and their functionality

| File Name    | Description  |
|--------------|--------------|
| `data.sql`   | Inserts initial user data into the `users` table. |
| `dropdb.sql` | Terminates active connections and drops the `final_capstone` database and associated users. |
| `schema.sql` | Drops existing tables if they exist and creates a new `users` table. |
| `user.sql`   | Creates database users (`final_capstone_owner` and `final_capstone_appuser`) and grants them necessary permissions. |


## Installation
1. [Download](https://www.docker.com/get-started/) and install Docker Desktop
1. Clone this repo
1. Move the files into your project using the guide below. *See: Moving files*

### Moving files

```
/
├── docker-compose.yml 
├── java/
│   └── database/
│       └── DatabaseDockerfile
│   └── JavaDockerfile
├── LICENSE
├── README.md
└── vue/
    └── VueDockerfile
```

Take the following files in this git project and move them as follows below:

| File Name    | Move to  |
|--------------|--------------|
| `docker-compose.yml`   | Root directory `/` |
| `java/JavaDockerfile` | Move to `/java` |
| `java/database/DatabaseDockerfile` | Move to `/java/database` |
| `vue/VueDockerfile`   | Move to `/vue` |

## How to use
1. `cd` into your capstone project
1. Run the command `docker compose up`
1. After it finishes build, go to `localhost:5173` in your browser to view your project running.
1. When finished, run the command `docker compose down`

## How it Works
*This section was written with the assistance of ChatGPT*
### Docker Compose Overview
Docker Compose orchestrates the setup and interconnection of three main services: the database, Java backend, and Vue frontend. It defines the network (`capstone-network`), volumes for data persistence, and the configuration for each service.

### Docker Compose Details
- **Services**:
  - **Database**: Built from `DatabaseDockerfile`, sets environment variables, maps port `5433`, and uses `postgres-data` volume.
  - **Java Backend**: Built from `JavaDockerfile`, exposes port `9000`, and connects to the database service.
  - **Vue Frontend**: Built from `VueDockerfile`, this service maps port `5173` for web access. It utilizes the `vue-node_modules` volume, which stores Node.js dependencies separately from the container's filesystem. This approach improves build performance and ensures consistency across development environments. The environment is set to development mode for optimal debugging and live reloading features.
- **Network**: `capstone-network` connects all services.
- **Volumes**: Named volumes like `postgres-data` and `vue-node_modules` for data persistence and dependencies.

### Database (`DatabaseDockerfile`)
- **Base Image**: `postgres:12-alpine`.
- **Initialization**: During this phase, SQL files are copied into the container. The `dropdb.sql` and `create.sh` files are removed to prevent unwanted execution. The remaining SQL files are then strategically renamed, following a numeric prefix system (`01schema.sql`, `02data.sql`, `03user.sql`). This renaming ensures their execution in a specific order, replicating the sequence originally managed by the `create.sh` script. This ordered execution is crucial for setting up the database schema, inserting initial data, and configuring user permissions correctly.
- **Docker Compose Integration**: This configuration exposes port `5433` on the host machine, which is mapped to the default PostgreSQL port `5432` inside the container. By mapping to port `5433` externally, it ensures there is no conflict with any existing PostgreSQL server running on the host machine's default port (`5432`). Additionally, it sets necessary environment variables for the database and utilizes the `postgres-data` volume for persistent storage of database data.


### Java Backend (`JavaDockerfile`)
- **Base Image**: `openjdk:11-slim`.
- **Setup**: Installs Maven, copies project files. Uses `sed` to dynamically alter `application.properties` inside the container, replacing the hardcoded database URL with environment variables (`${DB_HOST:db}` and `${DB_PORT:5432}`) for flexible database connectivity.
- **Execution**: Downloads dependencies, exposes port `9000`, and runs the application with Maven.

### Vue Frontend (`VueDockerfile`)
- **Base Image**: `node:alpine`.
- **Setup**: This step involves installing project dependencies first. Then, it modifies the `vite.config.js` file using the `sed` command. Specifically, `sed` is used to insert a configuration snippet that sets the server host to `0.0.0.0`. This adjustment is crucial because, without it, the Vite server would default to `localhost`, making the website inaccessible from the host machine. Setting the host to `0.0.0.0` ensures the Vite development server can be accessed externally, allowing you to view and interact with your Vue application from your computer's browser.
- **Execution**: Exposes port `5173` and runs the Vite development server.

This setup guarantees that each part of your application operates independently in a controlled environment, ensuring uniform behavior across different systems and enhancing the ease of transferring and deploying your application to various platforms.


## FAQ

### Does it modify any of my capstone files?
No, it is completely nondestructive and leaves your capstone files alone. After running `docker compose up` run `git status` in your repo to verify nothing was edited.

### Why not just start my server in IntelliJ and do `npm run dev`?
This Docker solution does not require IntelliJ, VS Code, npm, Postgres, or anything else to be installed on your computer.

### Should I use this Docker solution to continue working on the project?
Yes and no. Because it is nondestructive, any edits you make to your code won't be reflected on the web browser until you `docker compose down` and `docker compose up` again. If you are actively working on the project, you are better off running IntelliJ and `npm run dev`. This Docker solution is best for showcasing and viewing your project, especially after Tech Elevator where you lose access to your development machine.

### Will this Docker setup help me deploy my capstone project to a cloud provider?
In theory, yes, but there would need to be modifications to make it production ready. You'd need to use environment variable and store secrets like usernames and passwords in the cloud provider. You'd also need to rebuild the web application so that it's ready for production. In other words, this Docker setup is designed to let you view and run your capstone project on any machine, but it's not designed for cloud deployment.