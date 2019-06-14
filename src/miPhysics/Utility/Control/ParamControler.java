package miPhysics;

public class ParamControler extends AbstractController
{


    long step=0;
    float previous_value;

    public ParamControler(PhysicalModel pm_,float rampTime,String name,String param_ ) {
        super(pm_,name,param_);
      params.put("rampTime",rampTime);
      params.put("vmin",new Float(0));
      params.put("vmax",rampTime*pm.getSimRate());

    }


    public void updateParams()
    {
        step++;
        if(step <= params.get("vmax") )    pm.changeParamOfSubset(linearScale(step),subsetName,param);
    }

    public void triggerRamp(float value)
    {
        params.put("min",previous_value);
        params.put("max",value);
        params.put("vmax",params.get("rampTime")*pm.getSimRate());//in case it changed
        computeLinearParams();
        step = 0;
        previous_value = value;
    }

    public void init(float value)
    {
        previous_value = value;
        params.put("min",value);
        params.put("max",value);
        computeLinearParams();
        pm.changeParamOfSubset(value,subsetName,param);
    }
}