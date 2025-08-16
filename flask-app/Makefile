run-redis:
	@docker run -d --name redis-server --rm -p 6379:6379 redis:latest
	@echo "🟢 Redis server is running"

stop-redis:
	@docker stop redis-server
	@echo "🔴 Redis server has been stopped"

up:
	@docker-compose up -d
	@echo "✅ Success"

down:
	@docker-compose down -v
	@echo "📛 Destroyed"

#check if both containers are running
check:
	@docker-compose ps
	@echo "✅ All services running boss"

#check logs
log-app:
	@docker-compose logs app

log-redis:
	@docker-compose logs redis

#checks inside app if redis is connected
x:
	@docker-compose exec app python -c "\
	import redis;\
	r = redis.Redis(host='redis', port=6379);\
	print('Can connect to Redis:', r.ping());\
	"

prune:
	@docker image prune -a

curl-health:
	@curl http://localhost:9999/health

# Pushing Docker Images to ECR

# Get AWS account ID and region
account:
	@aws sts get-caller-identity --query Account --output text

# Login to ECR
login:
	@aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-2.amazonaws.com

# Tag image for ECR
tag:
	@docker tag docker-exercise-3-app <account-id>.dkr.ecr.us-east-2.amazonaws.com/flask-app:latest

# Push image to ECR
push:
	@docker push <account-id>.dkr.ecr.us-east-2.amazonaws.com/flask-app:latest