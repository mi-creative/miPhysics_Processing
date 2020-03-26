package miPhysics.Control;


import miPhysics.Engine.PhysicsContext;

import java.util.Map;
import java.util.HashMap;


// This should be re-coded / refactored with the param enum type (in Enums)
// specifying parameters by name isn't very clean.

public class AbstractController
{

    Map<String,Float> params = new HashMap<String,Float>();

    protected PhysicsContext pc;
    protected     String param;
    protected     String subsetName;
    protected float a;
    protected float b;

    public AbstractController(PhysicsContext pc_, String name, String param_)
{
    pc = pc_;
    param = param_;
    subsetName = name;
}

public void setParam(String param,float value){params.put(param,value);}

public String getSubsetName(){return subsetName;}

void computeScale()
{

}


float linearScale(float val)
{
    return a*val +b;
}

void computeLinearParams()
{
    a = (params.get("max")-params.get("min"))/(params.get("vmax")-params.get("vmin"));
    b = params.get("max") - a*params.get("vmax");
}

}