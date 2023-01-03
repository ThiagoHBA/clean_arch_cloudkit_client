//
//  ErrorHandler.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 02/01/23.
//

import Foundation
import CloudKit

struct CloudKitError: LocalizedError, CustomStringConvertible {
    var cloudKitErrorDescription: String
    var recoverySuggestion: String?
    
    var description: String {  return
        "\(cloudKitErrorDescription) \(recoverySuggestion ?? "")"
    }
}

class CloudKitErrorHandler: DataSourceErrorHandler {
    func handleError(_ error: Error) -> Error {
        if let ckError = error as? CKError {
            switch ckError.code {
            case .networkUnavailable:
                return CloudKitError(
                    cloudKitErrorDescription: "Internet não disponível!",
                    recoverySuggestion: "Verifique sua conexão e tente novamente"
                )
            case .networkFailure:
                return CloudKitError(
                    cloudKitErrorDescription: "Não foi possível concluir a operação devido uma falha na comunicação da internet!",
                    recoverySuggestion: "Verifique sua conexão e tente novamente"
                )
            case .serviceUnavailable:
                return CloudKitError(
                    cloudKitErrorDescription: "Serviço indisponível!",
                    recoverySuggestion: "Tente novamente mais tarde"
                )
            case .requestRateLimited:
                return CloudKitError(
                    cloudKitErrorDescription: "O limite máximo de requisições foi atingido!",
                    recoverySuggestion: "Tente novamente mais tarde"
                )
            case .notAuthenticated:
                return CloudKitError(
                    cloudKitErrorDescription: "Usuário não autenticado!",
                    recoverySuggestion: "Verifique sua conta e tente novamente"
                )
            case .accountTemporarilyUnavailable:
                return CloudKitError(
                    cloudKitErrorDescription: "Conta iCloud indisponível!",
                    recoverySuggestion: "Verifique sua conta iCloud e tente novamente"
                )
            case .permissionFailure:
                return CloudKitError(
                    cloudKitErrorDescription: "Usuário sem permissão para concluir essa operação!",
                    recoverySuggestion: "Verifique sua conta e tente novamente!"
                )
            case .serverRecordChanged:
                return CloudKitError(
                    cloudKitErrorDescription: "Não foi possível realizar a operação devido há um conflito de informações entre o aplicativo e o servidor!",
                    recoverySuggestion: "Atualize o aplicativo e tente novamente!"
                )
            case .serverRejectedRequest:
                return CloudKitError(
                    cloudKitErrorDescription: "Essa solicitação foi recusada pelo servidor",
                    recoverySuggestion: "Tente novamente mais tarde!"
                )
            case .incompatibleVersion:
                return CloudKitError(
                    cloudKitErrorDescription: "Ocorreu um conflito de versões!",
                    recoverySuggestion: "Atualize o aplicativo e tente novamente!"
                )
            case .assetFileNotFound:
                return CloudKitError(
                    cloudKitErrorDescription: "Não foi possível encontrar o arquivo solicitado no servidor!"
                )
            case .assetNotAvailable:
                return CloudKitError(
                    cloudKitErrorDescription: "O sistema não pôde acessar o arquivo solicitado!"
                )
            case .assetFileModified:
                return CloudKitError(
                    cloudKitErrorDescription: "O arquivo foi alterado enquanto estava sendo salvo",
                    recoverySuggestion: "Se as modificações não foram realizadas, tente novamente!"
                )
            case .unknownItem:
                return CloudKitError(cloudKitErrorDescription: "O registro solicitado não existe!")
            case .changeTokenExpired:
                return CloudKitError(
                    cloudKitErrorDescription: "Sua sessão se esgotou!",
                    recoverySuggestion: "Realize o login novamente para utilizar o aplicativo!"
                )
            case .zoneBusy:
                return CloudKitError(
                    cloudKitErrorDescription: "O servidor apresentou problemas para lidar com a operação",
                    recoverySuggestion: "Tente novamente em alguns segundos!"
                )
            case .quotaExceeded:
                return CloudKitError(
                    cloudKitErrorDescription: "O usuário não possui espaço suficiente!",
                    recoverySuggestion: "Libere espaço na sua conta iCloud e tente novamente"
                )
            case .limitExceeded:
                return CloudKitError(
                    cloudKitErrorDescription: "A solicitação realizada é muito grande!",
                    recoverySuggestion: "Diminua a quantiade de itens presentes na solicitação e tente novamente!"
                )
            case .tooManyParticipants:
                return CloudKitError(
                    cloudKitErrorDescription: "Não foi possível compartilhar os dados pois foi excedido o número de compartilhamentos autorizados"
                )
            case .managedAccountRestricted:
                return CloudKitError(
                    cloudKitErrorDescription: "A solicitação foi negada devido a uma restrição a conta!"
                )
            case .serverResponseLost:
                return CloudKitError(
                    cloudKitErrorDescription: "Resposta do servidor perdida",
                    recoverySuggestion: "Aguarde alguns minutos e tente novamente!"
                )
            case .alreadyShared:
                return CloudKitError(
                    cloudKitErrorDescription: "A operação não pôde ser concluida pois o registro já foi compartilhado!"
                )
            case .participantMayNeedVerification:
                return CloudKitError(
                    cloudKitErrorDescription: "O usuário não está autorizado a verificar o item compartilhado!"
                )
            case .internalError,
                    .partialFailure,
                    .missingEntitlement,
                    .badContainer,
                    .invalidArguments,
                    .resultsTruncated,
                    .constraintViolation,
                    .operationCancelled,
                    .batchRequestFailed,
                    .badDatabase,
                    .zoneNotFound,
                    .userDeletedZone,
                    .referenceViolation:
                return CloudKitError(
                    cloudKitErrorDescription: "Ocorreu um problema interno!",
                    recoverySuggestion: "Verifique se existe alguma atualização do aplicativo disponível. Se o error persistir, busque suporte em nossos canais de comunicação"
                )
            @unknown default:
                return CloudKitError(
                    cloudKitErrorDescription: "Erro não mapeado!",
                    recoverySuggestion: "Verifique se existe alguma atualização do aplicativo disponível e tente novamente."
                )
            }
        }
        return error
    }
}
