var AppWrapper = React.createClass({
    render: function() {
        return (
            <h1>Big sales</h1>
        )
    }
});

React.render(
    <AppWrapper />,
    document.getElementById("wrapper")
)