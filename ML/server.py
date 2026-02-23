import pandas as pd
import joblib
from fastapi import FastAPI
from pydantic import BaseModel

scaler_standard = joblib.load("s_scaler.pkl")
scaler_robust   = joblib.load("r_scaler.pkl")
scaler_minmax   = joblib.load("m_scaler.pkl")

model_water = joblib.load('gpr_model_water.pkl')
model_food = joblib.load('gpr_model_food.pkl')
model_time = joblib.load('gpr_model_time.pkl')

cols_standard = [
    'weight_kg',
    'height_cm',
    'time_per_1km_min',
    'VO2max_mlkg_min',
    'backpack_weight_kg',
    'avg_temp_C'
]

cols_robust = [
    'total_ascent_m'
]

feature_names = model_time.feature_names_in_

# описание входного JSON
class InputData(BaseModel):

    age: float
    sex: float
    weight_kg: float
    height_cm: float
    time_per_1km_min: float
    VO2max_mlkg_min: float
    distance_km: float
    backpack_weight_kg: float
    avg_temp_C: float
    humidity_pct: float
    total_ascent_m: float

app = FastAPI()


@app.post("/predict")
def predict(data: InputData):

    # JSON → dict
    data_dict = data.dict()

    # dict → DataFrame
    X = pd.DataFrame([data_dict], columns=feature_names)

    # scaling
    X[cols_standard] = scaler_standard.transform(X[cols_standard])
    X[cols_robust] = scaler_robust.transform(X[cols_robust])
    X = pd.DataFrame(
        scaler_minmax.transform(X),
        columns=feature_names
    )

    # predict
    water = model_water.predict(X)[0]
    food = model_food.predict(X)[0]
    time = model_time.predict(X)[0]

    return {
        "water": float(water),
        "food": float(food),
        "time": float(time)
    }