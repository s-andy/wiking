if (typeof jsToolBar.prototype.mention_rule != 'undefined') {
    jsToolBar.prototype.elements.space6 = {
        type: 'space'
    };
    jsToolBar.prototype.elements.mention = {
        type: 'button',
        title: 'User',
        fn: {
            wiki: function() {
                this.encloseSelection(this.mention_rule);
                $(this.textarea).trigger('keyup');
            }
        }
    };
}

jsToolBar.prototype.elements.more = {
    type: 'button',
    title: 'More',
    fn: {
        wiki: function() {
            window.open(this.more_link, '', 'resizable=yes, location=no, width=300, height=640, menubar=no, status=no, scrollbars=yes');
        }
    }
};
