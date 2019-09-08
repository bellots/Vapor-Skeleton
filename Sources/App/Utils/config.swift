/*
 
 docker run --name {{{{Skeleton | lowercase}}}} -e POSTGRES_DB=vapor   -e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password   -p 5432:5432 -d {{Skeleton | lowercase}}
 Lista images => docker ps -la
 docker start {{Skeleton | lowercase}}
   revert --all --yes
 
 docker-compose build
 docker-compose run --rm start_dependencies
 docker-compose up {{Skeleton | lowercase}}
 
 docker-compose down
 docker volume prune
 
 */
