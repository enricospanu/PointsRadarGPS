using Toybox.Application;
using Toybox.Activity;
using Toybox.WatchUi;
using Toybox.Math;

class Points extends Application.AppBase
{ function getInitialView() {return [new DataField()];} }

class DataField extends WatchUi.DataField
{
    var c=0, x,y,fg, r, p,ps; //lat, lon, d, a, r, n
    const rd=0.017453292519943295, es=6;

    function initialize() { DataField.initialize();
        var set=new[10], pr=Application.getApp(), prs=0;
        for(var i=0,gp=null; i<10; i++) {
            gp=pr.getProperty("p"+i.toString());
            if(gp!=null && gp.length()>8){set[prs]=gp; prs++;}}
        ps=es*prs; p=new[ps+es];
        for(var i=0,si=0,sub; i<prs; i++,si+=es) {
            sub=set[i];
            for(var j=0,cm,nn; j<2; j++) {
                cm=sub.find(",");
                if(cm!=null) {
                    nn = sub.substring(0,cm);
                    sub = sub.substring(cm+1,sub.length());
                    if(j==1){p[si+5]=sub;}
                } else {nn=sub;}
                p[si+j]=nn.toFloat()*rd; }}}


    function d(t1, n1)
    { var d,maxd=0.01;
        for(var i=2,t2,n2,dy,dx,nn,ct1; i<ps; i+=es) {
            t2=p[i-2]; n2=p[i-1];
            dy=t1-t2; nn=n2-n1;
            ct1 = Math.cos(t1);
            dx = ct1*nn;
            p[i+1] = atan2(dy,dx);
            d = 12742*Math.asin(Math.sqrt(0.5-Math.cos(dy)/2+ct1*Math.cos(t2)*(1-Math.cos(nn))/2));
            if(d>maxd){maxd=d;} p[i]=d; }

        if(maxd>10) {maxd=10.0;}
        var maxr = r/maxd;
        for(var i=2,rr; i<ps; i+=es) {
            d=p[i]; if(d<=maxd){rr=maxr*d;} else {rr=r;}
            p[i+2]=rr;
            p[i]=d.format("%.2f"); }}


    function onUpdate(dc)
    { var info = Activity.getActivityInfo();
        c++;
        if(c>10) {c=0; var g=info.currentLocation;
        if(g){
            if(p[p.size()-2]==null && info.startLocation!=null){
                var s=info.startLocation.toRadians();
                p[ps]=s[0]; p[ps+1]=s[1]; p[ps+5]="s"; ps+=es;}
            g=g.toRadians(); d(g[0],g[1]);} }

        if(p[3]){ var xp,yp,h,rr, z=new[ps/es*2];
        dc.setColor(0x888888,-1);
        for(var i=2,j=0; i<ps; i+=es,j+=2) {
            h = p[i+1]-info.currentHeading;
            rr = p[i+2];
            xp = x+Math.cos(h)*rr;
            yp = y+Math.sin(h)*rr;
            if(p[i+3]!=null){dc.drawText(xp-3,yp-3,0,  p[i+3],  4);}
            z[j]=xp; z[j+1]=yp;}
        dc.setColor(fg,-1);
        for(var i=2,j=0; i<ps; i+=es,j+=2) {
            xp=z[j]; yp=z[j+1];
            dc.fillRectangle(xp-1, yp-1, 3,3);
            pix_nr(dc, p[i], xp+3, yp-2);}

        dc.fillRectangle(x, y, 3,3); }}


    function onLayout(dc) {
        x = dc.getWidth()/2;
        y = dc.getHeight()/2;
        if (x<=y) {r=x-25;}
        else {r=x-y; r=r>=25?(y-4):(y-(25-r));}
        fg = getBackgroundColor() ^ 0xFFFFFF; }


    const nr =
        [1,1,1, 1,0,1, 1,0,1, 1,0,1, 1,1,1,
         0,1,0, 1,1,0, 0,1,0, 0,1,0, 1,1,1,
         1,1,1, 0,0,1, 1,1,1, 1,0,0, 1,1,1,
         1,1,1, 0,0,1, 1,1,1, 0,0,1, 1,1,1,
         1,0,1, 1,0,1, 1,1,1, 0,0,1, 0,0,1,
         1,1,1, 1,0,0, 1,1,1, 0,0,1, 1,1,1,
         1,1,1, 1,0,0, 1,1,1, 1,0,1, 1,1,1,
         1,1,1, 0,0,1, 0,1,1, 0,1,0, 0,1,0,
         1,1,1, 1,0,1, 1,1,1, 1,0,1, 1,1,1,
         1,1,1, 1,0,1, 1,1,1, 0,0,1, 1,1,1];

    function pix_nr(dc, txt, cx, cy) {
        for (var i=0; i<txt.length(); i++) {
            var t=txt.substring(i,i+1).toNumber();
            if (t!=null) {
                t*=15; var nr_pos=0;
                for(var yy=cy; yy<cy+5; yy++) {
                    for(var xx=cx; xx<cx+3; xx++) {
                        if (nr[t+nr_pos]) {dc.drawPoint(xx, yy);}
                        nr_pos++; }
                } cx+=4;
            } else {dc.drawPoint(cx, cy+4); cx+=2;} }}

    function atan2(y, x) {
        var z=0; if (x!=0) {z=Math.atan(y/x);}
        if (x<0) {z+=Math.PI*(y>=0?1:-1);}
        else if (x==0) {z=Math.PI/2*(y>0?1:-1); if(y==0){z=0;} }
        return z; }
}