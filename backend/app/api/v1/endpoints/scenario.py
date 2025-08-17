from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import json
from app.schemas.scenario import Scenario, ScenarioCreate, ScenarioUpdate
from app.services.scenario_service import scenario_service
from app.core.database import get_db

router = APIRouter(prefix="/scenarios", tags=["scenarios"])

@router.get("/", response_model=List[Scenario])
def read_scenarios(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    获取场景列表
    """
    scenarios = scenario_service.get_scenarios(db, skip=skip, limit=limit)
    
    # 处理字符列表的JSON转换
    for scenario in scenarios:
        if isinstance(scenario.characters, str):
            scenario.characters = json.loads(scenario.characters)
            
    return scenarios

@router.post("/", response_model=Scenario)
def create_scenario(scenario: ScenarioCreate, db: Session = Depends(get_db)):
    """
    创建新场景
    """
    db_scenario = scenario_service.create_scenario(db, scenario=scenario)
    return db_scenario

@router.get("/{scenario_id}", response_model=Scenario)
def read_scenario(scenario_id: int, db: Session = Depends(get_db)):
    """
    根据ID获取场景
    """
    db_scenario = scenario_service.get_scenario(db, scenario_id=scenario_id)
    if db_scenario is None:
        raise HTTPException(status_code=404, detail="Scenario not found")
    
    return db_scenario

@router.put("/{scenario_id}", response_model=Scenario)
def update_scenario(scenario_id: int, scenario: ScenarioUpdate, db: Session = Depends(get_db)):
    """
    更新场景
    """
    db_scenario = scenario_service.update_scenario(db, scenario_id=scenario_id, scenario_update=scenario)
    if db_scenario is None:
        raise HTTPException(status_code=404, detail="Scenario not found")
    
    return db_scenario

@router.delete("/{scenario_id}")
def delete_scenario(scenario_id: int, db: Session = Depends(get_db)):
    """
    删除场景
    """
    success = scenario_service.delete_scenario(db, scenario_id=scenario_id)
    if not success:
        raise HTTPException(status_code=404, detail="Scenario not found")
    return {"message": "Scenario deleted successfully"}

@router.get("/templates/", response_model=List[Scenario])
def read_templates(db: Session = Depends(get_db)):
    """
    获取所有可用的场景模板
    """
    templates = db.query(ScenarioModel).filter(ScenarioModel.template.isnot(None)).all()
    # 处理字符列表的JSON转换
    for template in templates:
        if isinstance(template.characters, str):
            template.characters = json.loads(template.characters)
    return templates