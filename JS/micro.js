
micro=function(micro,container,manager)
{
	// Instantiate the Dialog
	this.conf=new load_conf();
	

	this.error=0;
	if(this.conf.error()<0)
	{ 
		this.error=this.conf.error();
		return;
	}
	
	var optionWindow={
						expand:true,
						width:"750px",
						isExpanded:false,
						close:false,
						modal:false,
						center:false,
						visible:true
					};
	this.currentMicro=this.conf.getMicros()[0];
	// document.getElementById("currentMicro").innerHTML=this.currentMicro;
	this.cloud();
	this.SelectMicro=new itemWindow(micro,container,manager, optionWindow);
	this.create_window(this.conf.getMicros());

	this.container=container;
	this.micro=micro;
	this.calendarMicro;
	this.lock=false;
	

	
	this.selectExperimentEvent=new YAHOO.util.CustomEvent("SelectExperiment",null);
	this.changeMicroEvent=new YAHOO.util.CustomEvent("ChangeMicro",null);
	
	this.unlockEvent=new YAHOO.util.CustomEvent("unLock",null);
	this.lockEvent=new YAHOO.util.CustomEvent("Lock",null);
	
	
	this.onReadyEvent=new YAHOO.util.CustomEvent("onReady",null);
	this.onFinishedEvent=new YAHOO.util.CustomEvent("onFinished",null);
	
}
micro.prototype.cloud=function()
{
	var word_list = [
      {text: this.currentMicro, weight: 20},
      {text: "Microscope", weight: 7.5, html: {"class": "vertical"}},
      {text: "Confocal", weight: 6.4},
      {text: "Lens", weight: 1, html: {"class": "vertical"}},
      {text: "Optico", weight: 3.2},
      {text: "Resolution", weight: 5},
      {text: "Scan", weight: 5, html: {"class": "vertical"}},
      {text: "Stitching", weight: 5},
      {text: "Detecting", weight: 5},
      {text: "Laser", weight: 4, html: {"class": "vertical"}},
      {text: "Green GFP", weight: 4},
      {text: "Analisys", weight: 3},
      {text: "Light", weight: 3, html: {"class": "vertical"}},
      {text: "Zoom", weight: 3},
      {text: "Bioinformatics", weight: 3, html: {"class": "vertical"}},
      {text: "unit", weight: 3},
      {text: "CNIO", weight: 3},
      {text: "Leica", weight: 3, html: {"class": "vertical"}},
      {text: "SP5-MP", weight: 2},
      {text: "SP5-WLL", weight: 2},
      {text: "Fluorescence", weight: 2},
      {text: "CCD", weight: 2, html: {"class": "vertical"}},  
      {text: "High", weight: 2},
      {text: "Content", weight: 2},
      {text: "Screening", weight: 2, html: {"class": "vertical"}},
      {text: "Objetive", weight: 2}
    ];
	document.getElementById("currentMicro").innerHTML="";
	$("#currentMicro").jQCloud(word_list);
}
micro.prototype.create_window=function(micros)
{
	// Select Microscope:<select id="micro" name="micro"></select>
	var label=document.createElement('label');
	label.innerHTML=imrc_labels['micro']['title'];
	this.selectMicro=document.createElement('select');
	this.selectMicro.setAttribute('id','micro');
	this.selectMicro.setAttribute('name','micro');
	
	for(var imicro=0;imicro<micros.length;imicro++)
	{
		var option=document.createElement("option");
		option.setAttribute('value',micros[imicro]);
		option.innerHTML=micros[imicro];
		this.selectMicro.appendChild(option);
	}
	
	this.SelectMicro.getHead().appendChild(label);
	this.SelectMicro.getHead().appendChild(this.selectMicro);
	
	YAHOO.util.Event.addListener(this.selectMicro,"change",this.check,this);
	
	// <p>Low Resolution Images Folder:
	// 	<div id="CalendarImages"></div>
	// 	<div id="aviablesExperiments">
	// 		<div class="title">Select Experiment:</div>
	// 		<div id="listExperiments"></div>
	// 	</div>
	// </p>

	var p=document.createElement('p');
	var label=document.createElement('label');
	label.innerHTML=imrc_labels['micro']['label1'];
	p.appendChild(label);
	
	
	var div=document.createElement('div');
	div.setAttribute('id','CalendarImages');
	p.appendChild(div);
	
	var aviablesExperiments=document.createElement('div');
	aviablesExperiments.setAttribute('id','aviablesExperiments');
	p.appendChild(aviablesExperiments);
	
	var div=document.createElement('div');
	div.className="title";
	div.innerHTML=imrc_labels['micro']['label2'];
	aviablesExperiments.appendChild(div);
	
	var div=document.createElement('div');
	div.setAttribute('id','listExperiments');
	aviablesExperiments.appendChild(div);
	
	this.SelectMicro.getBody().appendChild(p);
	
	this.calendarMicro=new calExperimentSelect("CalendarImages",this.conf.getDirImages(),'listExperiments');
	
	
	this.calendarMicro.selectExperiment.subscribe(function(event,args,me){
		me.unlockEvent.fire();
		me.selectExperimentEvent.fire(args);
	},this);
	
	
	
	var input=document.createElement('input');
	input.setAttribute('type','button');
	input.setAttribute('id','RefreshdirImages');
	input.setAttribute('name','RefreshdirImages');
	input.setAttribute('value',imrc_labels['micro']['button1']);

	this.SelectMicro.getFooter().appendChild(input);
	new YAHOO.widget.Button("RefreshdirImages");
	
	YAHOO.util.Event.addListener(document.getElementById('RefreshdirImages'),"click",this.refresh,this);
	
}

micro.prototype.getSelectExperiment=function()
{
	return this.calendarMicro.getSelectExperiment();
}
micro.prototype.setSelectExperiment=function(CurrentExperiment)
{
	this.refresh(null,this);
		
	this.calendarMicro.selectDays(this.conf.getDirImages());	
	this.calendarMicro.selectDayExperiment(CurrentExperiment);
	return this.calendarMicro.setSelectExperiment(CurrentExperiment);
}
// micro.prototype.getParams=function()
// {
// 	var params={'micro':'','experimentDir':''};
// 	params.micro=this.currentMicro;
// 	params.experimentDir=this.getSelectExperiment();
// 	
// 	return params;
// }
micro.prototype.show=function()
{
	if(this.conf.error()==0)
	{
		this.SelectMicro.show();
		return 0;
	}
	return -1;
}


micro.prototype.refresh=function(event,me)
{
	
	me.conf.reload();	
	me.check("isUse",me);
	me.conf.changeTemplates(me.currentMicro);
	me.conf.changeDirImages(me.currentMicro);
	me.changeMicroEvent.fire(me.currentMicro);
	me.calendarMicro.selectDays(me.conf.getDirImages());
	
	if(!me.lock)
	{
		me.unlockEvent.fire();
	}
	else
	{
		me.lockEvent.fire();
	}
}
micro.prototype.getAllMicros=function()
{
	return this.conf.getAllMicros();
}
micro.prototype.getCurrentMicro=function()
{
	return this.currentMicro;
}

micro.prototype.setCurrentMicro=function(nameMicro)
{
	var options=this.selectMicro.getElementsByTagName('option');
	for(var i=0;i<options.length;i++)
	{
		if(options[i].getAttribute('value') == nameMicro)
		{
			options[i].setAttribute('selected',true);
			this.currentMicro=nameMicro;
			
			this.check('setCurrentMicro',this);
			
			return true;
		}
		else
		{
			options[i].setAttribute('selected',false);		
		}
	}
	return false;
}
micro.prototype.check=function(event,me)
{
	var url='cgi-bin/checkRun.cgi?conf='+document.getElementById("micro").value;

	
	var http_request;
	http_request = new XMLHttpRequest();
    http_request.open("GET", url, false);
    http_request.send(null);

	// var name;
	if(this.value != undefined)
	{
		// name=this.value;
		me.currentMicro=this.value;
		me.cloud();
		// document.getElementById("currentMicro").innerHTML=this.value;
		
	}
	else
	{
		if(event == 'setCurrentMicro')
		{
			me.cloud();
		}
		return;
	}
	var MyObj=me;
	me.lock = eval(http_request.responseText);
	
	if(me.lock)
	{
		var dialog = 
			new YAHOO.widget.SimpleDialog("message", 
					 { width: "300px",
					   fixedcenter: true,
					   visible: false,
					   draggable: false,
					   modal:true,
					   close: true,
					   icon: YAHOO.widget.SimpleDialog.ICON_WARN,
					   constraintoviewport: true,
					   buttons: [ { text:"Ok", handler:function() {
							this.hide();}, isDefault:true },
							{ text:"unLock", handler:function(event,me) {
																	var adminUrl='admin/cgi-bin/unlock.cgi?conf='+document.getElementById("micro").value;
																	var http_request;

																	http_request = new XMLHttpRequest();

																    http_request.open("GET", adminUrl, false);
																    http_request.send(null);
																	this.hide();
																	MyObj.unlockEvent.fire();
																}
												}]
					 } );
		dialog.render(document.body);
		dialog.setHeader("Warn");
		dialog.setBody('<p>Micro in use, select other micro or please wait or click unlock</p>');
		dialog.show();
		me.lockEvent.fire();
	}
	else
	{
		me.unlockEvent.fire();
	}
	
	if(event != "isUse")
	{
		me.conf.changeTemplates(me.currentMicro);
		me.conf.changeDirImages(me.currentMicro);
		me.changeMicroEvent.fire(me.currentMicro);
		me.calendarMicro.selectDays(me.conf.getDirImages());
	}
}
micro.prototype.isUse=function()
{
	this.check("isUse",this);
	return this.lock;
}
