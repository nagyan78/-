import os
import json
from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.scenario import Scenario
from app.schemas.scenario import ScenarioCreate, ScenarioUpdate

class ScenarioService:
    """
    场景服务类
    处理场景相关的业务逻辑
    """
    
    def get_scenario(self, db: Session, scenario_id: int) -> Optional[Scenario]:
        """
        根据ID获取场景
        """
        scenario = db.query(Scenario).filter(Scenario.id == scenario_id).first()
        if scenario and scenario._characters is None:
            scenario._characters = "[]"
        return scenario

    def get_scenarios(self, db: Session, skip: int = 0, limit: int = 100) -> List[Scenario]:
        """
        获取场景列表
        """
        scenarios = db.query(Scenario).offset(skip).limit(limit).all()
        # 确保_characters字段不为None
        for scenario in scenarios:
            if scenario._characters is None:
                scenario._characters = "[]"
        return scenarios

    def create_scenario(self, db: Session, scenario: ScenarioCreate) -> Scenario:
        """
        创建新场景
        """
        # 确保characters字段不为空
        if scenario.characters is None:
            scenario = scenario.copy(update={"characters": "[]"})

        db_scenario = Scenario(
            title=scenario.title,
            description=scenario.description,
            location=scenario.location,
            time_of_day=scenario.time_of_day,
            characters=scenario.characters
        )
        db.add(db_scenario)
        db.commit()
        db.refresh(db_scenario)
        # 确保_characters字段不为None
        if db_scenario._characters is None:
            db_scenario._characters = "[]"
        return db_scenario

    def update_scenario(self, db: Session, scenario_id: int, scenario_update: ScenarioUpdate) -> Optional[Scenario]:
        """
        更新场景信息
        """
        db_scenario = db.query(Scenario).filter(Scenario.id == scenario_id).first()
        if not db_scenario:
            return None
            
        # 确保_characters字段不为None
        if db_scenario._characters is None:
            db_scenario._characters = "[]"
            
        update_data = scenario_update.dict(exclude_unset=True)
        for key, value in update_data.items():
            if value is not None:
                setattr(db_scenario, key, value)
                
        db.commit()
        db.refresh(db_scenario)
        # 确保_characters字段不为None
        if db_scenario._characters is None:
            db_scenario._characters = "[]"
        return db_scenario

    def delete_scenario(self, db: Session, scenario_id: int) -> bool:
        """
        删除场景
        """
        db_scenario = db.query(Scenario).filter(Scenario.id == scenario_id).first()
        if not db_scenario:
            return False
            
        db.delete(db_scenario)
        db.commit()
        return True

scenario_service = ScenarioService()