<cfscript>
	function generateArgumentList(thisMethod) {
		var result = "";
		var i = "";
		var argCount = arrayLen(thisMethod.arguments);
		for (i = 1; i LTE argCount; i = i + 1) {
			result = result & generateArgument(thisMethod.arguments[i]);
			if (i LT argCount)
				result = result & ", "; 
		}
		return result;
	}
	
	function generateArgument(argument) {
		var result = "";
		var argUrl = "";
		if (NOT argument.required)
			result = result & "["; 
		argUrl = util.getDetailURL(argument.type,stComponent.path);
		if (not findNoCase("unknowncomponent",  argUrl) ){
			result = result & '<ulink url="#argUrl#">#listLast(argument.type, '.')#</ulink> #argument.name#';
		} else {
			result = result & '#listLast(argument.type, '.')# #argument.name#';
		}
		if (NOT argument.required) {
			if (structKeyExists(argument, "default")) {
				result = result & '="' & argument["default"] &'"';
			}
			result = result & "]";
		}
		return result;
	}
	
</cfscript>