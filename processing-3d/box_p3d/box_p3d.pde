void setup()
{
    size(450, 200, P3D);
}

void draw()
{
    background(245, 238, 184);
    fill(246, 225, 65);
    
    pushMatrix();
    translate(width/3, height/2);
    rotateX(-PI/6);
    rotateY(radians(frameCount));
    box(50);
    popMatrix();
    
    pushMatrix();
    translate( (width/3) * 2, height/2);
    rotateX(-PI/6);
    rotateY(radians(frameCount+45));
    box(50, 40, 100);
    popMatrix();
}
