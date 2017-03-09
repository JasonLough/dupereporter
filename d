/**
 * Created by alex on 6/16/14.
 */

$(function(){

    var $form = $('form.blueprint-form')
    $form.find('div.alert').hide();

    if(typeof $form.attr('data-meta') != 'undefined') {
        var $fileInp= $('input[type=file]');
        var $parentDiv = $fileInp.closest('div');

        if($parentDiv.hasClass('customFileInp')){
            var $buttonWrap = $parentDiv.find('span#customFileInpSpan');
            var $chooseFileMaskBtn = $buttonWrap.find('input[type=button]');
            var $statusElem = $chooseFileMaskBtn.siblings('span#statusTxt');
            var noFileTxt = $statusElem.text();

            $chooseFileMaskBtn.click(function () {
                $fileInp.click();
            })
            //
            $fileInp.change(function () {
                var $elem = this;

                var tets = $statusElem;

                var $val = null;
                if ($elem.value.indexOf("\\") != -1) {
                    $val = $elem.value.split('\\').pop().trim();
                }
                else if ($elem.value.indexOf("/") != -1) {
                    $val = $elem.value.split('/').pop().trim();
                }
                else {
                    $val = noFileTxt
                }

                $statusElem.text($val);
            })

        }
    }

    $(document).on('submit','form.blueprint-form',function(event){

        var form = $(this);
        form.find('div.alert').hide();

        //reset all validations
        form.find('div.form-group').removeClass('has-success').removeClass('has-error').removeClass('has-warning');
        var processData = false;
        var isIe9 = false;

        if(typeof(browser)=='object'){
            browser.getIEVersion();
            if(browser.docModeIE==9){
                processData = true;
                isIe9 = true;
                var formdata = {};
                formdata.append = function(field,value) {
                    this[field] = value;
                };

                form.find('input,select,textarea').each(function(){
                    var elem = $(this);
                    if ( (elem.attr('name') || '') !== '' &&  elem.is('[type="file"]') == false) {
                        formdata[elem.attr('name')] = elem.val();
                    }
                });
            }
        }
        if (isIe9 === false){
            var formdata = new FormData( form[0] );
        }

        var formRawData = form.serializeArray();
        var mappedData = {};
        $.each(formRawData,function(){
            if (this.name.indexOf('[]') > 0) {
                var noBracketName = this.name.substr(0,this.name.indexOf('[]'));
                if (undefined == mappedData[noBracketName]) {
                    mappedData[noBracketName] = [];
                }
                mappedData[noBracketName].push(this.value);
            } else {
                mappedData[this.name] = this.value;
            }
        });

        var hasErrors = false;
        //validate required
        form.find('div.form-group.required').each(function(){
            var group = $(this);
            group.find('input,select,textarea').each(function(){
                var field = $(this);
                var name = field.attr('name').indexOf('[]') > 0 ? field.attr('name').substr(0,this.name.indexOf('[]')) : field.attr('name');
                if (undefined == mappedData[name] || mappedData[name].length == 0 || mappedData[name]=="") {
                    group.addClass('has-error');
                    hasErrors = true;
                }
                field.unbind('change').on('change',function() {
                    group.removeClass('has-error');
                });
            });
        });

        form.find('div.form-group[data-type=captcha]').each(function(){
            if(!form.find('.g-recaptcha-response').val()){
                hasErrors = true;
            }
        });

        if (hasErrors) {
            form.find('div.alert.alert-missing-fields').fadeIn();
        } else {

            //validate for custom regex validations
            var customErrorMessage = "";
            form.find('div.form-group[data-validation]').each(function(){

                var container = $(this);
                var input = container.find('input');
                var regex = new RegExp(container.attr('data-validation'));
                var msg = container.attr('data-errormsg') || "Invalid Entry";
                var success = regex.test($.trim(input.val()));
                if (!success) {
                    hasErrors = true;
                    container.addClass('has-error');
                    customErrorMessage += "<li>"+ msg +"</li>";
                }

            });

            if (hasErrors) {
                form.find('div.alert.alert-custom-errors').html(customErrorMessage).fadeIn();
            } else {
                // no validation error try to submit
                form.find('input[type="submit"]').attr('disabled','disabled');

                formdata.append( 'formMeta', form.attr('data-meta') );
                formdata.append( 'signature', form.attr('data-signature') );
                formdata.append( 'fieldData', JSON.stringify( mappedData ) );

                var omitedFields = [];
                form.find("[omitfromdefaulthtmlemail='true']").each( function(){
                    omitedFields.push( $(this).attr("name") );
                });
                formdata.append( 'omitFromDefaultHtml', JSON.stringify(omitedFields) );
                if (isIe9 === true){
                    delete formdata.append;
                }

                if(form.find('.g-recaptcha-response')){
                    formdata.append('recaptcha',form.find('.g-recaptcha-response').val());
                }

                var formAjax = {
                    url: window.rootloc+'libs/formProcessor' + window.siteExtension,
                    type: 'POST',
                    data: formdata,
                    processData: processData  // tell jQuery not to process the data
                };

                if (isIe9 === true){
                    formAjax.dataType = "json";
                } else {
                    formAjax.dataType = "json";
                    formAjax.contentType = false;
                }

                $.ajax(formAjax).done(function(data){
                    if( data === 'success' || data.substring(0,14).toLowerCase() == 'customsuccess:' ) {

                        if( data.substring(0,14).toLowerCase() == 'customsuccess:' ){
                            form.find('div.alert.alert-success').html(data.substring(14));
                        }

                        form.find('div.alert.alert-success').fadeIn();

                        var metaAttr = $.parseJSON( form.attr('data-meta') );

                        var gaclickeventcategory = metaAttr.hasOwnProperty( 'data-gaclickeventcategory' ) ? $(metaAttr).prop('data-gaclickeventcategory') : '';
                        var gaclickeventaction = metaAttr.hasOwnProperty( 'data-gaclickeventaction' ) ? $(metaAttr).prop('data-gaclickeventaction') : '';
                        var gaclickeventlabel = metaAttr.hasOwnProperty( 'data-gaclickeventlabel' ) ? $(metaAttr).prop('data-gaclickeventlabel') : '';

                        var uptracsclickkpi = metaAttr.hasOwnProperty( 'data-uptracsclickkpi' ) ? $(metaAttr).prop('data-uptracsclickkpi') : '';

                        if(bpAnalyticsMethod !== 'signal') {
                            if (gaclickeventcategory.length && gaclickeventaction.length) {
                                if (typeof ga != 'undefined') {
                                    var trackers = ga.getAll();
                                    for (var i = 0; ( i < trackers.length ); ++i) {

                                        var tracker = trackers[i];
                                        thisTracker = ga.getByName(tracker.get('name'));
                                        thisTracker.send('event', gaclickeventcategory, gaclickeventaction, gaclickeventlabel);
                                    }
                                }
                            }

                            if (uptracsclickkpi.length) {
                                var mobileView = ( $('.hidden-xs:first').is(':hidden') ) ? 'Mobile ' : '';
                                uptracs('track', 'kpi', mobileView + uptracsclickkpi);
                            }
                        }

                        //execute submit callback if there is one
                        if (undefined != window['submit-' + form.attr('id')]) {
                            window['submit-' + form.attr('id')](form);
                        }

                    }
                    else {

                        if( data.substring(0,12).toLowerCase() == 'customerror:' )
                        {
                            form.find('div.alert.alert-processing-error').html(data.substring(12));
                        }

                        form.find('div.alert.alert-processing-error').fadeIn();

                    }
                    form.get(0).reset();
                    form.find('input[type="submit"]').removeAttr('disabled');

                });
            }

        }

        event.preventDefault();
        event.stopPropagation();
    });

    if(typeof(browser)=='object'){
        browser.getIEVersion();
        if(browser.docModeIE==9){

            inp=$('input[Placeholder],textarea[Placeholder]');
            inp.each(function(){
                if($(this).attr('Placeholder')!=''){
                    $(this).before($('<label for="'+$(this).attr('id')+'">'+$(this).attr('Placeholder')+'</label>'));
                }
            });
        }
    }

});
