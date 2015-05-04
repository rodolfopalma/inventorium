var LandingJumbotron = React.createClass({
        render: function() {
            return (
                <div className="container">
                    <Slideshow />
                </div>
            )
        }
    }),

    Slideshow = React.createClass({
        getInitialState: function() {
            return {slided: false, signed_up: false}
        },
        render: function() {
            var slided_class = this.state.slided ? "slided" : ""
            return (
                <div className="slideshow clearfix">
                        <IntroducingSlide data={this.state} />
                        <FormSlide />
                </div>
            )
        }
    }),

    IntroducingSlide = React.createClass({
        render: function() {
            return (
                <div className="container">
                    <h1 className="col-md-12">
                        Optimiza tu inventario, ahora.
                    </h1>

                    <p className="col-md-8">
                        Cada vez que tus productos quedan sin <em>stock</em>,
                        son liquidados por fin de temporada, o se
                        acumulan en bodega pierdes dinero.
                    </p>

                    <p className="col-md-8">
                        Inscríbete en BigSales y empieza a ganar
                        más dinero a través de nuestro sistema predictor
                        de demandas. 
                    </p>

                    <p className="col-md-8">
                        Usamos un avanzado modelo ingenieril
                        de investigación de operaciones que garantiza la
                        gestión eficiente de tus inventarios.
                    </p>

                    <SignUpButton data={this.data} />
                </div>

            )
        }
    }),

    FormSlide = React.createClass({
        render: function() {
            return (
                <div className="container">
                    <h2 className="col-md-12">
                        Inscribe a tu empresa en BigSales
                    </h2>

                    <p className="col-md-8">
                        Nuestro equipo se contactará contigo a la brevedad.
                    </p>

                    <form className="col-md-8">
                        <div className="form-group">
                            <label for="name_input">Nombre Completo</label>
                            <input id="name_input" type="text" placeholder="Juan Pérez García" className="form-control" />
                        </div>

                        <div className="form-group">
                            <label for="email_input">Correo Electrónico</label>
                            <input id="email_input" type="email" placeholder="juan@example.com" className="form-control" />
                        </div>

                        <div className="form-group">
                            <label for="company_input">Empresa / Compañía</label>
                            <input id="company_input" type="text" placeholder="El Emporio de Juan" className="form-control" />
                        </div>

                        <button type="submit" className="btn btn-default">Enviar</button>
                    </form>
                </div>
            )
        }
    }),

    SignUpButton = React.createClass({
        handleClick: function(event) {
            event.preventDefault()
            
            this.setState({signed_up: !this.state.signed_up, slided: true})
        },
        render: function() {
            var text;

            console.log(this.state)

            if(this.state.signed_up) {
                text = "Gracias por inscribirte. Te contactaremos pronto."
            } else {
                text = "Inscribe tu empresa en la Versión Beta"
            }

            return (
                <p className="col-md-8">
                    <a onClick={this.handleClick} className="btn btn-primary btn-lg" role="button">
                        {text}
                    </a>
                </p>
            )
        }
    })


React.render(
    <LandingJumbotron />,
    document.getElementById("landing_jumbotron")
)