from locust import HttpUser, task
import string
import random

# service_frontend = "http://frontend-service.default.svc:3000"
service_frontend = "http://localhost:3000"

def id_generator(size=6, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))

def name_generator():
    names = ["james", "michael", "robert", "john", "david", "william", "richard", "joseph", "thomas", "christopher"]
    return random.choice(names)

# id_generator()
# 'G5G74W'
# id_generator(3, "6793YUIO")
# 'Y3U'

class HelloWorldUser(HttpUser):
    host = service_frontend

    @task
    def hello_world(self):
        self.client.get("/")

    @task
    def random_process(self):
        self.client.get("/random/process")
    
    @task
    def auth_pass(self):
        self.client.get("/auth/pass")

    @task
    def auth_fail(self):
        self.client.get("/auth/fail")

    @task
    def list_products(self):
        self.client.get("/list/products")

    @task
    def get_couch(self):
        self.client.get("/products/couch/1")
    
    @task
    def get_users(self):
        self.client.get("/users")
    
    @task
    def create_users(self):
        # self.client.get("/users/new/" + id_generator())
        self.client.get("/users/new/" + name_generator())

    @task
    def health(self):
        self.client.get("/health")