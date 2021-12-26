#!/bin/bash
## lcfile.sh
## Este script busca por todos os arquivos de um local especificado em outro local, também especificado.
## Se encontrar o arquivo ele os compara para saber se são iguais.
## Se forem diferentes ele pode copia-lo para o destino considerando o diretório de destino compatível em dois níveis.
## Versão 1.0.0:
##.

#
MSG="
Manual \n\n
Uso: $(basename "$0") [OPÇÕES]\n\n


Este script testa se os arquivos de uma pasta existem no endereço informado.\n
Os endereços devem ser informados na linha de comando, porém existe a possibilidade\n
 de criar um arquivo de configuração para uso repetitivo\n
</etc/rgr/lcfile.conf>.\n
Se não houver configuração será apresentado a opção para inserir nova configuração\n
Também é possível excluir um caminho de origem e destino via linha de comando.\n

Estes parâmetros [OPÇÕES] tem a seguinte função:\n

OPÇÕES:\n
-h\t 	--help\t\t 	Chama o help do script i.e. $0 -h ou --help\n
-V\t 	--version\t Informa a versão do script i.e. $0 -V ou --version\n
-s\t	--setup\t	Cria o arquivo de configuração se ele não existir i.e. $0 -s ou --setup\n
-i\t	--insert\t	Salva um conjunto de endereços de origem e destino i.e. $0 -i ou --insert /xx/xxx/... /xx/xxxx/...\n
-d\t	--delete\t	Deleta um conjunto de endereços de origem e destino i.e. $0 -d ou --delete /xx/xxx/... /xx/xxxx/...\n
-p\t    --path\t    Neste caso o diretório de origem e destino são passados por linha de comando i.e. $0 -p ou --path /xx/xxx/... /xx/xxxx/...\n
-n\t	--nrecursivo\t Para buscas não recursivas i.e. $0 -n ou --nrecursivo /xx/xxx/... /xx/xxxx/...\n


"

log_search() {
	echo -e "$1" >> duplicados.txt;
	echo -e "\t  $2\n">>duplicados.txt;
}

lc_file() {
	ORIGEM=$1;
	AREADEBUSCA=$2;
	RECURSIVO=$3;
#	echo "Recursivo: "$RECURSIVO;
#	read x
	for pathname in "$ORIGEM"/*; do
#		if [[ -d "$pathname" ]] && [[ $RECURSIVO == 1 ]]; then
		if [[ -d "$pathname" ]]; then
            echo "ChangeDir" "$pathname";
            echo "Processing File" "${pathname##*/}";
#            lc_file \""$pathname"\" \""$AREADEBUSCA"\" \""$RECURSIVO"\";
			lc_file "$pathname" "$AREADEBUSCA" "$RECURSIVO";
#			read stop;
        else
        	for arq in $pathname; do
		        echo "Processing File" "${pathname##*/}";
#                echo -e "File meam" $ORIGEM${pathname##*/} >> duplicados.txt;
				if [ -f "$pathname" ]; then 
                    comandot="(find \"$AREADEBUSCA\" -type f -name \"${pathname##*/}\")";
#
#					procurado="$(echo -e "${pathname##*/}")";
#					arrayfiles=()
#					while IFS=  read -r -d $'\0'; do
#						arrayfiles+=("$REPLY")
#					done < <(find \"$AREADEBUSCA\" -type f -name \"${pathname##*/}\" -print0)
#					done < <(find \"$AREADEBUSCA\" -type f -name \"Conselho de Mulher.mp3\")
#					done < <(echo "find \"$AREADEBUSCA\" -type f -name \"Conselho de Mulher.mp3\"" -print0)
#					#done < < eval "$comandot";
#
#					read STPOPARRAY;
#
                 else
						comandot="";
				fi
                if [ "$comandot" != "" ]; then
                    if eval "$comandot"; then
						LC_FILE=$(eval "$comandot");
						ARQ_ORIGEM=$ORIGEM${pathname##*/};
						echo "LC_FILE-:$LC_FILE";
						LC_FILE=$(echo -e "${LC_FILE//$ARQ_ORIGEM/\"}");
						echo "LC_FILE-.-:$LC_FILE";
						LC_FILE="$(echo -e "${LC_FILE}" | sed -e 's/^[[:space:]]*// ' | sed -e 's/^[^/]*//')"
						echo "LC_FILE-..-:$LC_FILE";
#						read STOP;
						echo -e "Localizado o arquivo ${pathname##*/}";
						echo "Comparando arquivos!.....";
						#comandot="(cmp \"$ORIGEM${pathname##*/}\" \"$AREADEBUSCA${pathname##*/}\")";
						comandot="cmp \"$ORIGEM/${pathname##*/}\" \"$LC_FILE\"";
						echo -e "$comandot";
#						read STOP2;
						if eval "$comandot"; then
							echo "Os arquivos: $ORIGEM/${pathname##*/} $AREADEBUSCA/${pathname##*/} são idênticos!...";
							if [ "$VERBO" ]; then
								log_search "File meam $ORIGEM/${pathname##*/}" "$LC_FILE\n"
								#	echo -e "\t  $LC_FILE\n">>duplicados.txt;
							fi	
						fi
#                       let "cont++";
					   ((cont++)) || true;
                    else
                        echo "Ocorreu erro ao buscar o arquivo: $pathname!...";
                        erro=1;
                    fi;
                fi    
			done
		fi;
	done	
}






## Função para testar se existe o arquivo de log
test_log() {
	log_tag="LCFILE";
	log_file="/var/log/lcfile.log";
	if  [[ ! -f  "$log_file" ]]; then
		if [ "$(id -u)" != "0" ]; then
            echo;
            echo -n "Digite a senha de root - ";
            su -root -c touch "$log_file";
        fi
         if ! (sudo touch "$log_file"); then
#        if ! (touch "$log_file"); then
			echo -e "Erro ao criar arquivo de log. Confira seus previlêgios!..."
			exit 1;
		else
		 	_message2="$(date +%d/%m/%Y)\t$(date +%H:%M):"
	 		echo -e "$log_tag\t$_message2\tArquivo de log criado com Sucesso!..." >> "$log_file";
		fi
	fi
}
## Função para escrever no arquivo de log 
log(){
	log_file="/var/log/lcfile.log";
	log_tag="LCFILE";	
	_message="$1"
	_message1="$(date +%d/%m/%Y)\t$(date +%H:%M):"
#	echo -e "$log_tag\t$_message1\t$_message" >> "$log_file";
	exit 0;
}
## Cria o arquivo de configuração se não existir
make_config() {
	log_file="/var/log/lcfile.log";
	log_tag="LCFILE";	
	DIR="/etc/rgr";
	ARQ_CONFIG="lcfile.conf";
	_config="$DIR/$ARQ_CONFIG";
	if  [[ ! -e "$_config" ]]; then
		if [[ "$USER" = "root" ]]; then
			if [[ ! -e "$DIR" ]]; then
				mkdir "$DIR";
			fi
			if [[ ! -e "$_config" ]]; then
				touch "$_config";
				echo -e "Arquivo de configuração criado!. Incluir Diretórios para teste agora? (s/n)"
				read opc;
				if [[ $opc = [sS] ]]; then
					echo -e "Digite o endereço de orígem do alvo a ser testado!";
					read DIR_ORIG;
					echo -e "Digite o endereço de destino do do teste!";
					read DIR_DEST					
                    echo -e "O endereço de orígem $DIR_ORIG, está correto? (s/n)";
                    read opc
                    while [[ "$opc" != [sS] ]]
                    do
                        read DIR_ORIG;
                        echo -e "O endereço de orígem $DIR_ORIG, está correto? (s/n)";
                        read opc
                    done
					echo -e "Digite o endereço de destino do do teste!";
					read DIR_DEST					
                    echo -e "O endereço de destino $DIR_DEST, está correto? (s/n)";
                    read opc;
                    while [[ "$opc" != [sS] ]]
                    do
                        read DIR_DEST;
                        echo -e "O endereço de destino $DIR_DEST, está correto? (s/n)";
                        read opc
                    done
                    echo -e "Confirma a gravação dos parâmetros no arquivo de configuração?";
                    read opc;
					if [[ $opc = [sS] ]]; then
						echo -e "$_config"
						echo -e "$IP_DEST" >> "$_config";
						exit 0;
					fi
				else
					echo -e " Não se esqueça de configurar o alvo de teste em: $_config";
					exit 0
				fi
			fi
		fi
	fi
}
insert_DIR() {
log_file="/var/log/lcfile.log";
log_tag="LCFILE";	
DIR="/etc/rgr";
ARQ_CONFIG="lcfile.conf";
_config="$DIR/$ARQ_CONFIG";
DIR_ORIG=$1;
DIR_DEST=$2;
if [ ! -n "$1" ] && [ ! -n "$2" ]; then
    echo -e "O endereço digitado foi $1, $2, está correto? (s/n)";
    read opc;
    if [[ $opc = [sS] ]]; then
        echo -e "$_config";
        echo -e "$DIR_ORIG"  "$DIR_DEST" >> "$_config";
        echo -e "Conjunto de endereços de pastas cadastrado com sucesso!";
        exit 0;
    else
        echo -e "Incluir caminhos das pastas agora? (s/n)"
        read opc;
        if [[ $opc = [sS] ]]; then
            echo -e "Digite o caminho de origem!";
            read DIR_ORIG;
            echo -e "Digite o caminho de destino!";
            read DIR_DEST;
            echo -e "O endereço digitado foi $DIR_DEST, $DIR_DEST, está correto? (s/n)";
            read opc;
            if [[ $opc = [sS] ]]; then
                echo -e "$_config";
                echo -e "$DIR_ORIG  $DIR_DEST" >> "$_config";
                echo -e "Conjunto de endereços de pastas cadastrado com sucesso!";
                exit 0;
            else
                exit 1;
            fi
        fi
    fi
fi   
}
# Função para deletar um determinado endereço do arquivo de configuração!
delete_DIR(){
log_tag="LCFILE";	
DIR="/etc/rgr";
ARQ_CONFIG="lcfile.conf";
_config="$DIR/$ARQ_CONFIG";
#echo $#
#printf '%s\n' "$@";
DIR_ORIG=$1;
DIR_DEST=$2;
	if [[ -n "$1" ]] || [[ -n "$2" ]]; then
        parametro="$1 $2";
        parametro=$(echo "$parametro" | sed 's/\//\\\//g');
        echo -e "$parametro";
		sed -i "/$parametro/d" $_config
		if [[ $? = 0 ]]; then
			echo -e "Conjunto de endereços de pastas deletado com sucesso!"
		else
			echo -e "Conjunto de testes não encontrado Verifique novamente! \n A seguir a lista de Diretório de Teste cadastrados!";
			cat $_config;
		fi
	fi
}

## Tratamento dos parâmetros de entrada.
## Início e tratamento das variáveis.
clear;
if [ "$(id -u)" != "0" ]; then
	echo;
	echo "Este script necessita de previlégios execute como root i.e. sudo ./acess_rede.sh";
	# exit 1;
fi
recursivo=0;
test_log;
#echo "Parâmetro:[ $1 : $2 : $3 : $4 : $5 ]";
#read x;
while [[ -n "$1" ]]
do
    case "$1" in
		-h | --help)
			echo -e $MSG;
			exit 0;
		;;
		-V | --version)
			# Extrair a versão do cabeçalho do script.
			grep '^## Versão ' "$0" | tail -1 | cut -d: -f 1 | tr -d \#
			exit 0;
		;;
		-v | --verbose)
			VERBO=1;
		;;
		-s | --setup)
			make_config;
			if [[ $? = 0 ]]; then
				exit 0;
			else
				exit 1;
			fi
		;;
		-i | --insert)
			shift
			insert_DIR $1 $2;
			if [[ $? = 0 ]]; then
				exit 0;
			else
				exit 1;
			fi
		;;
		-d | --delete)
			shift
			delete_DIR $1 $2;
			if [[ $? = 0 ]]; then
				exit 0;
			else
				exit 1;
			fi
		;;
       -p | --path)
            caminho=1;
            shift;
            DIR_ORIG=$1;
            shift;
            DIR_DEST=$1;
			shift
		;;
        -n | --nrecursive)
            recursivo=1;
            shift;
        ;;

		*)
			clear;
			echo "O parâmetro [OPÇÃO] $1 digitado não foi reconhecido pelo script!"
			exit 1;
		;;
	esac
done

clear;
if [[ $caminho -eq 1 ]]; then
    if [ ! -d "$DIR_ORIG" ] || [ ! -d "$DIR_DEST" ]; then
        echo "Você precisa especificar um diretório válido!"
        echo "O script será finalizado!"
        exit 1;
     else
        echo -e "Iniciando a procura por arquivos com mesmo nome!";
        # Aqui chama a função para localizar os arquivos passando como parâmetros aqueles passados por linha de comando.
        echo -e "lc_file $DIR_ORIG $DIR_DEST $recursivo";
#        lc_file "$DIR_ORIG" "$DIR_DEST" "$recursivo";
     fi
else
    # Aqui chama a mesma função passando agora os parâmetros constante do arquivo de configuração.
    echo -e "Usando o caminho cadastrado no arquivo de configuração!...";
	rm duplicados.txt;
    echo -e "lc_file $DIR_ORIG $DIR_DEST $recursivo"; 

#    lc_file "$DIR_ORIG" "$DIR_DEST";
fi

# parei aqui

lastChar_ORIG="${DIR_ORIG: -1}";
lastChar_DEST="${DIR_DEST: -1}";
if [ "$lastChar_ORIG" = "/" ]; then
    DIR_ORIG=$(echo $DIR_ORIG | sed -r 's/.$//g');
    echo $DIR_ORIG;
else
    echo $DIR_ORIG;
fi
if [ "$lastChar_DEST" = "/" ]; then
    DIR_DEST=$(echo $DIR_DEST | sed -r 's/.$//g');
    echo $DIR_DEST;
else
    echo $DIR_DEST;
fi

if [ -d "$DIR_ORIG" ] && [ -d "$DIR_DEST" ]; then
	rm duplicados.txt;
	echo -e "lc_file $DIR_ORIG $DIR_DEST"; 
	lc_file "$DIR_ORIG" "$DIR_DEST" "$recursivo";
#    lc_file "$DIR_ORIG" "$DIR_DEST";
    echo "********ATENÇÃO!!!*********";
    echo "Foram encontrados $cont arquivos! iguais no diretório de ORIGEM e DESTINO!";
    if [[ $erro -eq "1" ]]; then
        echo "Ocorreram erros na busca por aquivos!"
    fi    
    exit 0;
else
    echo "********ATENÇÃO!!!*********";
    echo "Um dos diretórios $DIR_ORIG ou $DIR_DEST não existe ou você não permissão de acessá-los!";
    echo $DIR_ORIG " - " $DIR_DEST;
    exit 1;
fi