from fastapi import FastAPI
from pydantic import BaseModel
from transformers import pipeline

app = FastAPI()
translator = pipeline("translation_en_to_fr", model="t5-small")

# Pydantic data struct for input
class In(BaseModel):
    text: str

# Model Inference logic
@app.post("/translate")
def translate(x: In):
    out = translator(x.text)
    return {"translation": out[0]["translation_text"]}