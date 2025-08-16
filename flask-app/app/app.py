from flask import Flask
import redis
import os

app = Flask(__name__)

#Connect to Redis using service name as hostname
try:
    r = redis.Redis(
        host=os.environ.get('REDIS_HOST', 'redis'), # Set the environment variable REDIS_HOST incase you use different DNS name for Redis
        port=int(os.environ.get('REDIS_PORT', '6379')),
        decode_responses=True
    )
     #Test connection
    r.ping()
    redis_available = True
except:
    redis_available = False

@app.route('/')
def hello():
    if redis_available:
        # Increment visit counter
        visits = r.incr('visits')
        return f'''
        <h1>Hello from Docker Compose!</h1>
        <p>This page has been visited <strong>{visits}</strong> times.</p>
        <p>Redis is connected and working! 🎉</p>
        <p><a href="/">Refresh to increment counter</a></p>
        '''
    else:
        return '''
        <h1>Hello from Docker Compose!</h1>
        <p>Redis is not available 😞</p>
        <p>Check your docker-compose.yml configuration</p>
        '''

@app.route('/health')
def health():
    status = {
        'app': 'healthy',
        'redis': 'connected' if redis_available else 'disconnected'
    }
    return status

if __name__ == '__main__':
    port = int(os.environ.get('PORT', '5000'))
    app.run(host='0.0.0.0', port=port, debug=True)