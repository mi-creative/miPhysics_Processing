package miPhysics;

public class LinkRenderProps{

    private int m_r;
    private int m_g;
    private int m_b;
    private int m_alpha;
    private int m_size;

    private boolean m_strain_gradient;

    private int m_r_strain;
    private int m_g_strain;
    private int m_b_strain;
    private int m_alpha_strain;

    private float m_stretch_max;

    public LinkRenderProps(int r, int g, int b, int alpha){
        m_r = r;
        m_g = g;
        m_b = b;

        m_alpha = alpha;
        m_size = 2;

        m_strain_gradient = false;
        m_stretch_max = 2;
    }

    public LinkRenderProps(int r, int g, int b, int alpha, int size){
        this(r,g,b,alpha);
        m_size = size;
    }

    public void setAlpha(int val){
        m_alpha = val;
    }
    public int getAlpha(){return m_alpha;}

    public int getColor(){
        return m_r << 16 + m_g << 8 + m_b;
    }

    /*public void setColor(int col){
        m_r = col >> 16 & 0xFF;
        m_g = col >> 16 & 0xFF;
        m_b = col & 0xFF;

    }*/


    public void setStrainGradient(boolean val, float max){
        m_strain_gradient = true;
        m_stretch_max = max;
    }

    public boolean strainGradient(){
        return m_strain_gradient;
    }

    public float getStrainMax(){
        return m_stretch_max;
    }


    public void setColor(int r, int g, int b, int alpha){
        m_r = r;
        m_g = g;
        m_b = b;
        m_alpha = alpha;
    }


    public void setStrainColor(int r, int g, int b, int alpha){
        m_r_strain = r;
        m_g_strain = g;
        m_b_strain = b;
        m_alpha_strain = alpha;
    }

    public int getStrainColor(){
        return m_alpha_strain << 24 + m_r_strain << 16 + m_g_strain << 8 + m_b_strain;
    }

    public int getStrainAlpha(){
        return m_alpha_strain;
    }

    public int getSize(){return m_size;}
    public void setSize(int size){m_size = size;}

    public int red(){return m_r;}
    public int green(){return m_g;}
    public int blue(){return m_b;}


    private int calcStretch(int col, int strain, float stretch){
        if(stretch < 0)
            return col;
        else if (stretch < m_stretch_max)
            return (int)(((m_stretch_max - stretch) * col + stretch * (float)strain)/m_stretch_max);
        else
            return strain;
    }

    public int redStretch(float stretch){
        return calcStretch(m_r, m_r_strain, stretch);
    }

    public int greenStretch(float stretch){
        return calcStretch(m_g, m_g_strain, stretch);
    }

    public int blueStretch(float stretch){
        return calcStretch(m_b, m_b_strain, stretch);
    }

    public int alphaStretch(float stretch){
        return calcStretch(m_alpha, m_alpha_strain, stretch);
    }
}