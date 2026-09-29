from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"mensaje": "Hola para TodoEnCloud. By Rafael Marin"}

